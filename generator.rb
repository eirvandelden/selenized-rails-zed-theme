require "yaml"
require "json"

# Read the YAML template file
template = YAML.load_file("selenized-template.yml")

# Extract the color map and basic template
color_map      = template["color_map"]
basic_template = template.dig("basic_template", "style")
themes         = template["themes"]

# Function to replace placeholders in the template with actual color values
def replace_placeholders(template, color_values)
  template.each_with_object({}) do |(key, value), result|
    if value.is_a?(String) && color_values.key?(value)
      result[key] = color_values[value]
    elsif value.is_a?(Hash)
      result[key] = replace_placeholders(value, color_values)
    else
      result[key] = value
    end
  end
end

# Generate the themes
generated_themes = themes.map do |theme_key, theme_info|
                      color_values = color_map[theme_key]
                      {
                        "name" => theme_info["name"],
                        "appearance" => theme_info["appearance"],
                        "style" => replace_placeholders(basic_template, color_values)
                      }
                    end

# Create the final JSON structure
output = {
  "$schema" => template["$schema"],
  "name" => template["name"],
  "author" => template["author"],
  "themes" => generated_themes
}

# Write the output to a JSON file
File.open("selenized-rails-theme.json", "w") do |file|
  file.write(JSON.pretty_generate(output))
end

puts "Generated selenized-rails-theme.json successfully!"
