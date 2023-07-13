capacity_raw=/sys/class/power_supply/bms/capacity_raw
capacity=/sys/class/power_supply/bms/capacity

if [[ -f /sys/class/qcom-battery/fg1_rsoc ]];then
setenforce 0
mount --bind /sys/class/qcom-battery/fg1_rsoc /sys/class/power_supply/battery/capacity
chcon u:object_r:vendor_sysfs_battery_supply:s0 /sys/class/power_supply/battery/capacity
setenforce 1
elif
[[ -f /sys/class/power_supply/bms/capacity_raw ]];then
function set_cap() {
    if [[ "$1" != "$current" ]]; then
        if [[ $1 -lt 1 ]]; then
            dumpsys battery set level 1
            return
        fi
        dumpsys battery set level $1
    fi
    if [ $? -eq 0 ]; then
        current="$1"
    fi
}

function capacity_raw() {
    [ -f $capacity_raw ] ||
        \ return
    while true; do
        local real=$(($(cat $capacity_raw)/100))
        set_cap "$real"
        sleep 5s
    done
}

function capacity() {
    [ -f $capacity ] ||
        \ return
    while true; do
        local real=$(($(cat $capacity)/100))
        set_cap "$real"
        sleep 5s
    done
}

function run() {
     sleep 5
    capacity_raw &
    capacity &
}

run &
fi