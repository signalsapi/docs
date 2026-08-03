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

  build_commands = File.read(File.join(ROOT, "Rakefile")).scan(/sh ["'][^"']*jekyll build[^"']*["']/)
  if build_commands.empty?
    site.fail!("the Rakefile invokes no `jekyll build` — the drafts exclusion this pins is no longer where it was")
  end
  drafty = build_commands.select { |command| command.include?("--drafts") }
  unless drafty.empty?
    site.fail!("`jekyll build` is invoked with --drafts (#{drafty.join(', ')}) — drafts would render into _site/")
  end

  draft_paths = Dir.glob(File.join(ROOT, "_drafts", "*.md"))

  offenders = []
  permalinks = []

  draft_paths.each do |path|
    content = File.read(path)
    front_matter = YAML.safe_load(content.split(/^---\s*$/, 3)[1], permitted_classes: [Date]) || {}

    offenders << "#{path}: missing owner" unless front_matter["owner"]
    offenders << "#{path}: missing a sign_off marker" unless front_matter.key?("sign_off")

    permalink = front_matter["permalink"]
    offenders << "#{path}: missing an explicit permalink" unless permalink
    permalinks << permalink if permalink
  end

  permalinks.each do |permalink|
    built_path = if permalink.end_with?("/")
                   File.join(ROOT, "_site", permalink, "index.html")
                 else
                   File.join(ROOT, "_site", permalink)
                 end
    offenders << "#{permalink} is present in the built site at #{built_path}" if File.exist?(built_path)
  end

  %w[sitemap.xml llms.txt llms-full.txt].each do |surface|
    surface_path = File.join(ROOT, "_site", surface)
    next unless File.exist?(surface_path)

    surface_content = File.read(surface_path)
    permalinks.each do |permalink|
      offenders << "#{permalink} appears in _site/#{surface}" if surface_content.include?(permalink)
    end
  end

  search_index_path = File.join(ROOT, "_site", "assets", "js", "search-data.json")
  if File.exist?(search_index_path)
    search_content = File.read(search_index_path)
    permalinks.each do |permalink|
      offenders << "#{permalink} appears in the lunr search index" if search_content.include?(permalink)
    end
  end

  site.fail!("_drafts/ violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
