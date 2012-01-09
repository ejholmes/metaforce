Metaforce
=========
Metaforce is a Ruby gem for creating, reading and modifying package.xml files for the force.com metadata API.

Usage
-----
Parse a package.xml file and add a component:

    package = Metaforce::Package.new(File.open('package.xml').read)
    package.add(:apex_class, 'ApexClassController')

Remove a component:

    package.remove(:apex_class, 'ApexClassController')
