banners
=======

  This module requires that figlet be installed on the Puppet Master(s) along with the doom font for figlet.
It sets up 3 files issue, issue.net (needs to be set as the banner in sshd_config) and motd.  Using figlet it 
will add the hostname as ASCII art into the motd i.e.

    # figlet -f doom wildajet
              _ _     _       _      _
             (_) |   | |     (_)    | |
    __      ___| | __| | __ _ _  ___| |_
    \ \ /\ / / | |/ _` |/ _` | |/ _ \ __|
     \ V  V /| | | (_| | (_| | |  __/ |_
      \_/\_/ |_|_|\__,_|\__,_| |\___|\__|
                            _/ |
                           |__/

