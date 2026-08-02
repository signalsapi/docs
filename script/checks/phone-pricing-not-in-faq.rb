# frozen_string_literal: true

Check.register(
  id: "phone-pricing-not-in-faq",
  desc: "faq.md has no currency symbol adjacent to the word 'phone', and 'propsects' appears nowhere",
  covers: ["2.8"]
) do |site|
  faq = site.raw("faq.md")

  faq.split(/\n\s*\n/).each do |paragraph|
    if paragraph =~ /phone/i && paragraph =~ /[£$€]/
      site.fail!("faq.md has a currency symbol adjacent to the word 'phone': #{paragraph.strip[0, 80]}")
    end
  end

  offenders = site.pages.select { |p| site.raw(p.path).include?("propsects") }
  site.fail!("the string 'propsects' appears in: #{offenders.map(&:path).join(', ')}") unless offenders.empty?
end
