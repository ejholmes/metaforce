# Metaforce [![travis-ci](https://secure.travis-ci.org/ejholmes/metaforce.png)](https://secure.travis-ci.org/ejholmes/metaforce)

Metaforce is a Ruby gem for interacting with the Salesforce [Metadata](http://www.salesforce.com/us/developer/docs/api_meta/index.htm) and [Services](http://www.salesforce.com/us/developer/docs/api/index.htm).

[Documentation](http://rubydoc.info/gems/metaforce/frames)

## Installation
```bash
gem install metaforce
```

## Contributing
If you'd like to contribute code, please fork the repository and implement your
feature on a new branch, then send me a pull request with a detailed
description. Please provide applicable rspec specs.

## Version History
**0.5.3** (June 8, 2012)
* Only trigger reauthentication if the response contains `INVALID_SESSION_ID`.

**0.5.2** (June 8, 2012)
* The services client now reauthentications on Savon::SOAP::Fault.

**0.5.1**

* Add thor integration.

**0.5.0** (March 23, 2012)

* Implemented CRUD calls.

**0.4.1** (March 8, 2012)

* Bug fixes

**0.4.0** (March 2, 2012)

* Various bug fixes and improvements.
* Removed DSL to focus on core functionality.

**0.3.5** (February 11, 2012)

* Allow rake tasks to get credentials from a metaforce.yml file.

**0.3.4** (February 9, 2012)

* Add rake tasks.

**0.3.3** (February 9, 2012)

* Added a logger for logging requests.
* Allow api version to be set when calling `Metaforce::Metadata::Client.describe`.

**0.3.2** (February 3, 2012)

* Improved documentation.
* Added `.status` method to Transaction class.

**0.3.1** (February 3, 2012)

* Dynamically defined helper methods for .list (e.g. `client.list_apex_class`, `client.list_custom_object`).
* The `Metaforce::Metadata::Client.describe` method now caches the results to minimize latency. `describe!`
  can be used to force a refresh.

**0.3.0.alpha** (January 29, 2012)

* Ability to retrieve metadata from an organization.
* Added a DSL.

**0.2.0.alpha** (January 28, 2012)

* Gem now supports interacting with the metadata api.

**0.1.0.alpha** (January 10, 2012)

* Ability to parse and modify package.xml files easily.

## License
Copyright (C) 2012  Eric Holmes

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
