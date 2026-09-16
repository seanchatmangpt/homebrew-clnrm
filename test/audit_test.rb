# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require_relative "../lib/tap_audit"

GOOD_SHA = "0677ed1c820997188b4012471e2d5ddbcbc9b86c63e752cdda6863b8f6f53a3d"

GOOD_FORMULA = <<~RUBY
  class Goodprobe < Formula
    desc "probe"
    homepage "https://example.com/goodprobe"
    url "https://github.com/example/goodprobe/archive/refs/tags/v1.2.3.tar.gz"
    sha256 "#{GOOD_SHA}"

    def install
      bin.install "goodprobe"
    end
  end
RUBY

class TapAuditTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir("tap_audit_test")
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def write_formula(name, body)
    path = File.join(@dir, "#{name}.rb")
    File.write(path, body)
    path
  end

  # --- unit: real subject ---

  def test_real_tap_formula_passes
    repo = File.expand_path("..", __dir__)
    assert_empty TapAudit.audit(File.join(repo, "Formula", "clnrm.rb"))
  end

  # --- unit: passing fixtures ---

  def test_good_fixture_passes
    assert_empty TapAudit.audit(write_formula("goodprobe", GOOD_FORMULA))
  end

  def test_explicit_version_matching_tag_passes
    body = GOOD_FORMULA.sub("  desc \"probe\"", "  version \"1.2.3\"\n  desc \"probe\"")
    assert_empty TapAudit.audit(write_formula("goodprobe", body))
  end

  def test_untagged_v_prefix_tag_passes
    body = GOOD_FORMULA.gsub("refs/tags/v1.2.3.tar.gz", "v1.2.3.tar.gz")
    assert_empty TapAudit.audit(write_formula("goodprobe", body))
  end

  # --- unit: each check fails closed ---

  def test_syntax_error_reported
    path = write_formula("broken", "class Broken < Formula\n  url \"https://example.com\nend\n")
    violations = TapAudit.audit(path)
    assert_equal 1, violations.length
    assert_includes violations.first, "syntax:"
  end

  def test_missing_stable_url_reported
    body = GOOD_FORMULA.sub(/^\s*url .*\n/, "")
    assert_includes TapAudit.audit(write_formula("goodprobe", body)).join, "stable url: missing"
  end

  def test_http_url_reported
    body = GOOD_FORMULA.gsub(%r{https://github}, "http://github")
    assert_includes TapAudit.audit(write_formula("goodprobe", body)).join, "must use https"
  end

  def test_short_sha256_reported
    body = GOOD_FORMULA.gsub(GOOD_SHA, "abc123")
    assert_includes TapAudit.audit(write_formula("goodprobe", body)).join, "not 64 hex"
  end

  def test_version_tag_mismatch_reported
    body = GOOD_FORMULA.sub("  desc \"probe\"", "  version \"9.9.9\"\n  desc \"probe\"")
    assert_includes TapAudit.audit(write_formula("goodprobe", body)).join,
                   "does not match version `9.9.9`"
  end

  def test_non_release_url_reported
    body = GOOD_FORMULA.gsub("archive/refs/tags/v1.2.3.tar.gz", "trunk/bundle.tar.gz")
    assert_includes TapAudit.audit(write_formula("goodprobe", body)).join, "cannot derive release tag"
  end

  def test_class_name_mismatch_reported
    assert_includes TapAudit.audit(write_formula("goodprobe", GOOD_FORMULA.gsub("Goodprobe", "Wrongname"))).join,
                   "does not match file name (expected `Goodprobe`)"
  end

  def test_expected_class_name_convention
    assert_equal "SomeFormulaName", TapAudit.expected_class_name("some-formula_name.rb")
    assert_equal "Clnrm", TapAudit.expected_class_name("clnrm.rb")
  end

  def test_audit_dir_fail_closed_on_empty_directory
    empty = File.join(@dir, "empty")
    Dir.mkdir(empty)
    assert_raises(ArgumentError) { TapAudit.audit_dir(empty) }
  end

  # --- integration: CLI end-to-end ---

  def test_cli_green_on_real_formula_dir
    repo = File.expand_path("..", __dir__)
    out, _err, status = Open3.capture3(File.join(repo, "script", "audit"),
                                       File.join(repo, "Formula"))
    assert status.success?, "expected exit 0, got #{status.exitstatus}: #{out}"
    assert_includes out, "OK clnrm.rb"
  end

  def test_cli_red_on_violating_formula_dir
    write_formula("badprobe", GOOD_FORMULA.gsub(%r{https://}, "http://"))
    repo = File.expand_path("..", __dir__)
    out, _err, status = Open3.capture3(File.join(repo, "script", "audit"), @dir)
    refute status.success?, "expected non-zero exit"
    assert_equal 1, status.exitstatus
    assert_includes out, "must use https"
    assert_includes out, "badprobe.rb"
  end

  def test_cli_usage_error_on_missing_path
    repo = File.expand_path("..", __dir__)
    _out, err, status = Open3.capture3(File.join(repo, "script", "audit"),
                                       File.join(@dir, "nope"))
    assert_equal 2, status.exitstatus
    assert_includes err, "no such file or directory"
  end
end
