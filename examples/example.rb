require 'metaforce'

# Run with: `USER=user PASS=pass TOKEN=securitytoken bundle exec ruby example.rb`

Metaforce.configuration.log = false

client = Metaforce.new :username => ENV['USER'],
  :password => ENV['PASS'],
  :security_token => ENV['TOKEN']

Metaforce::Job.disable_threading!

# Test sending an email.
print 'send email to: '
client.send_email(
  to_addresses: [STDIN.gets.chomp],
  subject: 'Test',
  plain_text_body: 'Test'
)

# Test deployment.
client.deploy('../spec/fixtures/payload.zip')
  .on_complete { |job| puts "Deploy Completed: #{job.id}."}
  .on_error    { |job| puts "Deploy Failed: #{job.id}."}
  .perform

# Test retrieve.
manifest = Metaforce::Manifest.new(:custom_object => ['Account'])
client.retrieve_unpackaged(manifest)
  .on_complete { |job| puts "Retrieve Completed: #{job.id}."}
  .on_error    { |job| puts "Retrieve Failed: #{job.id}."}
  .extract_to('./tmp')
  .perform

# Test delete.
client.delete(:apex_page, 'TestPage')
  .on_complete { |job| puts "Delete Completed: #{job.id}."}
  .on_error    { |job| puts "Delete Failed: #{job.id}."}
  .perform

# Test create.
client.create(:apex_page, :full_name => 'TestPage', label: 'Test page', :content => '<apex:page>foobar</apex:page>')
  .on_complete { |job| puts "Create Completed: #{job.id}."}
  .on_error    { |job| puts "Create Failed: #{job.id}."}
  .perform

# Test update.
client.update(:apex_page, 'TestPage', :full_name => 'TestPage', :label => 'Test page', :content => '<apex:page>hello world</apex:page>')
  .on_complete { |job| puts "Update Completed: #{job.id}."}
  .on_error    { |job| puts "Update Failed: #{job.id}."}
  .perform
