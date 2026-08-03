# frozen_string_literal: true

# _drafts/ is excluded from site.pages (CONTENT_EXCLUDED_DIRS), so this
# reads it directly. Jekyll itself already skips _drafts/ without the
# --drafts flag (rake check never passes it) — this is the paired
# assertion making that guarantee explicit and catching a future
# permalink collision or a draft that leaks into a generated surface.
#
# _drafts/ is allowed to be empty. This used to open with a pin on the
# corpus — `site.fail!("_drafts/ has no files") if draft_paths.empty?` —
# which turned _drafts/ into a one-way door: Story 9.7 parked its draft
# here precisely so it could later be published or deleted, and both of
# those dispositions empty the directory and so failed the build. The pin
# was guarding against a real hazard (an assertion with nothing to assert
# passes vacuously), so it is replaced rather than dropped: the two facts
# that actually make the guarantee true are pinned instead, and they have
# teeth at zero drafts.
Check.register(
  id: "drafts-not-published",
  desc: "No file under _drafts/ appears in the built site or any machine-readable surface; each draft carries an owner and a sign-off marker; the exclusion mechanism stays pinned when _drafts/ is empty",
  covers: ["9.7"]
) do |site|
  unless Site::CONTENT_EXCLUDED_DIRS.include?("_drafts")
    site.fail!("Site::CONTENT_EXCLUDED_DIRS no longer excludes _drafts/ — a draft would be audited as a published page")
  end

  build_commands = site.raw("Rakefile").scan(/sh ["'][^"']*jekyll build[^"']*["']/)
  if build_commands.empty?
    site.fail!("the Rakefile invokes no `jekyll build` — the drafts exclusion this pins is no longer where it was")
  end
  drafty = build_commands.select { |command| command.include?("--drafts") }
  unless drafty.empty?
    site.fail!("`jekyll build` is invoked with --drafts (#{drafty.join(', ')}) — drafts would render into _site/")
  end

  draft_paths = site.glob("_drafts/*.md")

  offenders = []
  permalinks = []

  draft_paths.each do |path|
    content = site.raw(path)
    front_matter = YAML.safe_load(content.split(/^---\s*$/, 3)[1], permitted_classes: [Date]) || {}

    offenders << "#{path}: missing owner" unless front_matter["owner"]
    offenders << "#{path}: missing a sign_off marker" unless front_matter.key?("sign_off")

    permalink = front_matter["permalink"]
    offenders << "#{path}: missing an explicit permalink" unless permalink
    permalinks << permalink if permalink
  end

  permalinks.each do |permalink|
    built_path = permalink.end_with?("/") ? "_site#{permalink}index.html" : "_site#{permalink}"
    offenders << "#{permalink} is present in the built site at #{built_path}" if site.exist?(built_path)
  end

  %w[sitemap.xml llms.txt llms-full.txt assets/js/search-data.json].each do |surface|
    next unless site.exist?("_site/#{surface}")

    surface_content = site.raw("_site/#{surface}")
    permalinks.each do |permalink|
      offenders << "#{permalink} appears in _site/#{surface}" if surface_content.include?(permalink)
    end
  end

  site.fail!("_drafts/ violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
