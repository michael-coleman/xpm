
xpm - X Pointer Manager
=======================


Why is this needed?
----------------

The underlying command which `xpm` uses to configure the X device wrapper `xinput --set-prop` is a single, rather simple-ish command line command.  

So why not just run this command directly? 2 reasons.  

1. `xinput --set-prop ...`  requires, as part of its command, an identifier for the target device.  
To get it means running and manually interpreting the output of `xinput --list` to get the identifier, then running a command to set your desired properties.  
The is addtionally complicated when you have a combo keyboard/mouse USB device which actually exposes 2 X input devices under the same identifier.
2. On top of that, this identifier changes when:

* The system is rebooted
* You plug in or un-plug your USB mouse
* Possibly (not 100% sure about this) when a laptop resumes after a suspend.

Usage
-----


### Get a copy of `xpm`

recommend you put `xpm` into a directory `~/.zsh/xpm`

    mkdir -p ~/.zsh && git clone https://github.com/michael-coleman/xpm.git  ~/.zsh/xpm

You tell it by way of a configuration file, `config.zsh` a unique identifier of a X pointer device you want configured.  
create a file: `config.zsh` in the `xpm` directory with contents something like:

    xpm_devices=( 
        "Logitech USB Receiver"
        "SynPS/2 Synaptics TouchPad"
    )


Then source `~/.zsh/xpm/xpm.zsh` from your `~/.zshrc`. you should now have a command/function: `xpm_status`
