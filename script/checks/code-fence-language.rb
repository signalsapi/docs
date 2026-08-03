# frozen_string_literal: true

Check.register(
  id: "code-fence-language",
  desc: "Every fenced code block declares a language",
  covers: ["5.5"]
) do |site|
  offenders = []

  site.pages.each do |page|
    in_fence = false
    page.body.each_line.with_index(1) do |line, line_no|
      stripped = line.strip
      next unless stripped.start_with?("```")

      if in_fence
        in_fence = false
      else
        lang = stripped[3..].to_s.strip
        offenders << "#{page.path}:#{line_no}" if lang.empty?
        in_fence = true
      end
    end
  end

  site.fail!("fenced code block(s) with no declared language — #{offenders.join(', ')}") unless offenders.empty?
end
