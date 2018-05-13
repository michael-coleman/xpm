
# xpm - X windows pointer manager
#
#set -o nounset

source $(dirname ${(%):-%N})/config.zsh

function _xpm_match_id_from_device_list() {
    local dev_name=${1}

    xinput list | 
        grep -i "${dev_name}.*pointer"  | grep -P --only '(?<=id=)[0-9]+'
}

function _xpm_get_device_id() {

    local dev_name=${1:?[error] dev_name not given}

    id=$( _xpm_match_id_from_device_list $dev_name )

    if [[ -n $id ]]
    then
        printf "%s" "$id"
    else
        echo "device: [ $1 ] not found - did you plug it in?"
    fi
}

function _xpm_is_device_connected() {
    local dev_name="$1"
    xinput list | grep $dev_name > /dev/null 2>&1
    return $?
}

function _xpm_print_const_decel() {
    local id=$1

    xinput list-props $id                          |
        grep "Device Accel Constant Deceleration"  |
        sed -n 's/^\s\+//p'       # strip whitespace start of line
}

function _xpm_print_ptr_feedbacks() {
    local id=$1

    xinput get-feedbacks $id     |
        sed -n '/accelNum/,+2{
            s/^\s\+//p
        }'                       |
        column -t
}

function _xpm_get_info_on_device() {
    local id=${1:?[error] id not given}
    echo "ID=$id"

    _xpm_print_const_decel "$id"

    _xpm_print_ptr_feedbacks "$id"
    echo
}

function _xpm_print_status_message() {

    local id

    for dev in "${xpm_devices[@]}"
    do
        # test if device is connected before id is extracted because it makes
        # no sense to try get the id of a non-existent device
        if _xpm_is_device_connected $dev
        then
            id=$(_xpm_get_device_id "$dev")
            echo `tput smso`"[$dev]"`tput rmso`
            _xpm_get_info_on_device $id
        else
            echo `tput smso`"[$dev]`tput rmso` doesn't seem to be connected"
            echo
        fi
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


