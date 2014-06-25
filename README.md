puppet-modules
=======

Puppet modules from throughout the years.  Use at your own risk!

These modules were written against Puppet enterprise with YAML being used via Hiera and files being served from the Puppet fileserver.  
All files that a module references are being pulled from the fileserver and are not stored in the module

There is a hiera array called sourcelookup that stores the hiera lookup order for example

    sourcelookup:
                  - ".%{::hostname}"
                  - ".%{::group}"
                  - ""

This is usually pulled into the module and appended to the file name so that in the file server I can override what files are being used
without touching the module.  This requires the puppetlabs/stdlib prefix function.


