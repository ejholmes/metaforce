# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :specs do
  guard :rspec do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/metaforce/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  end
end
