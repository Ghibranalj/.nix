#!/usr/bin/env sh
# rofi config
echo -en "\0markup-rows\x1ftrue\n"

# set session if not set
if [[ -z "$SESSION" ]]; then
    SESSION="qemu:///system"
fi

function set_status() {
    echo -en "\0message\x1f$1\n"
}

_virsh() {
    virsh -c "$SESSION" $@
}

run_virsh() {
    # replace Domain with VM
    local status=$(_virsh $@ | sed "s/^Domain/Virtual machine/g")
    set_status "$status"
}

vm_man() {
    virt-manager -c "$SESSION" $@
}

log() {
    echo "$@" 1>&2;
}

# $1: text
# $2: next state
function button() {
    echo -en "$1\0info\x1f$2\n"
}

function select_line() {
    echo -en "\0active\x1f$1\n"
}

function print_vm_list(){
    VM=$1
    MACHINE_LIST=$(
            _virsh list --all |\
                awk '/^ -/ || /^ [0-9]+/ {sub(/^ -/,"");sub(/^ [0-9]+/, "");sub(/^\s*/,""); print}')
    # loop through all machines
    local i=0
    while read -r line; do
        # get machine name
        name=$(echo $line | awk '{print $1}')
        # get machine state
        state=$(echo $line | awk '{print $2 " " $3}')
        TEXT=$(printf "%-22s <small>%s</small> \n" "$name" "$state")

        if [[ "$name" == "$VM" ]]; then
            button "$TEXT" "main;;"
        else
            button "$TEXT" "$name;;"
        fi

        if [[ "$state" == "running"* ]]; then
            select_line $i
        fi

        if [[ $name == $VM ]]; then
            if [[ "$state" != "running"* ]]; then
                button "        Start" "$name;start;$name"
                i=$((i + 1))
            fi
            if [[ "$state" != "paused"*  && "$state" != "shut"* ]]; then
                button "        Pause" "$name;pause;$name"
                button "        Stop" "$name;stop;$name"
                i=$((i + 2))
            fi
            if [[ "$state" != "shut"* ]]; then
                button "        Force Stop" "$name;destroy;$name"
                i=$((i + 1))
            fi
            button "   🖥️    Open" "$name;open;$name"
            button "    ⚙     Configure" "$name;config;$name"
            i=$((i + 2))
        fi

        i=$((i + 1))
    done <<< "$MACHINE_LIST"
}

function main_menu(){
    print_vm_list ''
}

function vm_menu(){
    print_vm_list $1
}


function main(){
    state=$(echo $ROFI_INFO | cut -d ';' -f1) # main ,{vm_name} , dangerous_action/{vm_name}
    action=$(echo $ROFI_INFO | cut -d ';' -f2) # open/start/stop
    vm=$(echo $ROFI_INFO | cut -d ';' -f3) # vm name

    if [[ -n "$vm" ]]; then
        vmstate=$(_virsh domstate $vm)
        log vmstate: $vmstate
    fi

    case "$action" in
        "open")
            vm_man --show-domain-console $vm &
            ;;
        "config")
            vm_man --show-domain-editor $vm &
            ;;
        "start")
            log vmstate: $vmstate
            if [[ "$vmstate" == "paused" ]]; then
                run_virsh resume $vm
            else
                run_virsh start $vm
            fi
            ;;
        "stop")
            run_virsh shutdown $vm
            ;;
        "destroy")
            run_virsh destroy $vm
            ;;
        "pause")
            run_virsh suspend $vm
            ;;
    esac

    case "$state" in
        "main")
            main_menu
            ;;
        *)
            vm_menu $state
            ;;
    esac
}

main
