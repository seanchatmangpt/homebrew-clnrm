# typed: false
# frozen_string_literal: true

# Offline, brew-audit-style validation for Homebrew tap formulas.
#
# Bounds (documented, by design): DSL fields (url/version/sha256) are matched
# where they appear as the first token of a line, which covers the standard
# formula layout; this is a line-oriented heuristic, not a full DSL parse, and
# it performs no network access and requires no Homebrew installation.

module TapAudit
  ARCHIVE_TAG =
    %r{/(?:archive/(?:refs/tags/)?|releases/download/[^/]+/)([^/?#]+)\.(?:tar\.gz|tgz|tar\.bz2|zip)\z}

  module_function

  # Audits a single formula file. Returns an Array of violation Strings;
  # empty means the formula passed every check.
  def audit(path)
    content = File.read(path)

    violations = check_syntax(path, content)
    return violations unless violations.empty? # later checks would be noise

    url = extract_dsl_string(content, "url")
    violations.concat(check_stable_url(path, url))
    violations.concat(check_sha256(path, content))
    violations.concat(check_version_tag(path, content, url))
    violations.concat(check_class_name(path, content))
  end

  # Audits every *.rb file under dir. Returns { absolute_path => violations }.
  # Raises ArgumentError when the directory holds no formulas (fail-closed).
  def audit_dir(dir)
    files = Dir.glob(File.join(dir, "*.rb")).sort
    raise ArgumentError, "no formula files found under #{dir}" if files.empty?

    files.map { |f| [File.expand_path(f), audit(f)] }.to_h
  end

  # Homebrew class-name convention: split the formula file name on -, _, .,
  # capitalize each part, join.
  def expected_class_name(formula_filename)
    File.basename(formula_filename, ".rb").split(/[-_.]+/).reject(&:empty?).map(&:capitalize).join
  end

  def check_syntax(path, content)
    RubyVM::AbstractSyntaxTree.parse(content)
    []
  rescue SyntaxError => e
    ["#{path}: syntax: #{e.message}"]
  end

  def extract_dsl_string(content, dsl)
    content[/^\s*#{dsl}\s+"([^"]+)"/, 1]
  end

  def check_stable_url(path, url)
    return ["#{path}: stable url: missing required stable `url`"] if url.nil?
    return ["#{path}: stable url: `#{url}` must use https"] unless url.start_with?("https://")

    []
  end

  def check_sha256(path, content)
    sha = content[/^\s*sha256\s+"([^"]+)"/, 1]
    return ["#{path}: sha256: missing checksum for stable url"] if sha.nil?
    return ["#{path}: sha256: `#{sha}` is not 64 hex characters"] unless sha.match?(/\A[0-9a-fA-F]{64}\z/)

    []
  end

  # Version/tag consistency: the stable url must reference a release tag, and
  # that tag must agree with the explicit `version` field when one is present
  # (tag == version or tag == "v" + version). Without an explicit version, the
  # tag must still derive a version-like string (contains a digit).
  def check_version_tag(path, content, url)
    tag = tag_from_url(url)
    return ["#{path}: version/tag: cannot derive release tag from `#{url}`"] if tag.nil?

    explicit = extract_dsl_string(content, "version")
    if explicit
      return [] if tag == explicit || tag == "v#{explicit}"

      return ["#{path}: version/tag: tag `#{tag}` does not match version `#{explicit}` " \
              "(expected #{explicit} or v#{explicit})"]
    end

    derived = tag.sub(/\Av/, "")
    return [] if derived.match?(/\d/)

    ["#{path}: version/tag: tag `#{tag}` yields `#{derived}`, which contains no digit"]
  end

  def tag_from_url(url)
    return nil if url.nil?

    url[ARCHIVE_TAG, 1]
  end

  def check_class_name(path, content)
    declared = content[/^\s*class\s+(\w+)\s*<\s*Formula\b/, 1]
    expected = expected_class_name(path)
    return ["#{path}: class name: no `class X < Formula` declaration found"] if declared.nil?
    return [] if declared == expected

    ["#{path}: class name: `#{declared}` does not match file name (expected `#{expected}`)"]
  end
end
