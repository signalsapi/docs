# frozen_string_literal: true

# AD-8: an unsourceable figure ships as a marker, never an invented number.
# The grammar is exactly `TODO(owner: <handle>): <what is needed>` - a
# well-formed marker never fails the build, a malformed one always does.
Check.register(
  id: "todo-owner-grammar",
  desc: "Every marker matches the grammar TODO(owner: <handle>): <what is needed>",
  covers: ["1.12"]
) do |site|
  well_formed_re = /\ATODO\(owner:\s*\S[^)]*\):\s*\S/
  malformed = []
  well_formed = []

  sources = site.pages.map { |p| [p.path, site.raw(p.path)] } +
            Dir.glob(File.join(ROOT, "_data", "*.{yml,yaml}")).map { |f| [f.sub("#{ROOT}/", ""), File.read(f)] }

  sources.each do |path, content|
    content.each_line.with_index(1) do |line, lineno|
      next unless (idx = line.index(/\bTODO\b/))

      candidate = line[idx..].strip
      entry = "#{path}:#{lineno}: #{candidate}"
      candidate.match?(well_formed_re) ? well_formed << entry : malformed << entry
    end
  end

  site.fail!("malformed TODO marker(s) — grammar is `TODO(owner: <handle>): <what is needed>`: #{malformed.join('; ')}") unless malformed.empty?

  unless well_formed.empty?
    puts "todo-owner-grammar: #{well_formed.size} marker#{well_formed.size == 1 ? '' : 's'} found:"
    well_formed.each { |m| puts "  - #{m}" }
  end
end
