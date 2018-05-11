
# xpm - X windows pointer manager
#
#set -o nounset

source $(dirname ${(%):-%N})/config.zsh

# note this function expects data on STDIN
function _xpm_get_id_out_of_xinput_device_list() {
    
    grep -i "${1}.*pointer"  |  # match the line only if it contains pointer. 
                                # This handles the case for USB Keyboard mouse
                                # combo's where the name refers to the combo,
                                # and the name appears twice in xinput's output

       grep -P --only '(?<=id=)[0-9]+'
}

function _xpm_get_device_id() {

    local dev_name=${1:?[error] dev_name not given}

    id=$( 
        xinput --list  |  
            _xpm_get_id_out_of_xinput_device_list $dev_name   
    )

    if [[ -n $id ]]
    then
        printf "%s" "$id"
    else
        echo "device: [ $1 ] not found - did you plug it in?"
    fi
}

function _xpm_print_status_message() {

    echo pointer devices loaded into X
    echo -----------------------------
    xinput --list | grep pointer
    echo

    echo Your pointer devices:
    echo 
    # for dev in ${xpm_devices[@]}
    for dev in $xpm_devices
    do
        echo "Device: $dev"
        xinput list-props $( _xpm_get_device_id "$dev" ) |
            grep "Device Accel Constant Deceleration"
        echo
    done

    cat <<- EOF
	you can set properties with something like:
	
	    xinput set-prop `tput smso`id`tput rmso` "Device Accel Constant Deceleration" `tput smso`threshold`tput rmso` 
	    xinput set-ptr-feedback `tput smso`id`tput rmso` `tput smso`threshold`tput rmso` `tput smso`numerator`tput rmso` `tput smso`denominator`tput rmso` 
	
	EOF

}

function _xpm_can_talk_with_Xorg_server() {
    xset q 1> /dev/null 2>&1   # if xset gives a 0 return code, X is available
}

function xpm_status() {

    if _xpm_can_talk_with_Xorg_server
    then
        _xpm_print_status_message
    else
        echo "your shell doesn't seem to be able to communicate with the X server"
    fi
}


