Metaforce
=========
Metaforce is a Ruby gem for creating, reading and modifying package.xml files for the force.com metadata API.

Usage
-----
Parse a package.xml file and add a component:

    package = Metaforce::Manifest.new(File.open('package.xml', 'r').read)
    package.add(:apex_class, 'ApexClassController')

Remove a component:

    package.remove(:apex_class, 'src/classes/ApexClassController.cls')

Save back out to a file:

    File.open('package.xml', 'w') do |file|
      file.write(package.to_xml)
    end
