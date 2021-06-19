#!/system/bin/sh
#
#ifdef VENDOR_EDIT
#jie.cheng@swdp.shanghai, 2015/11/09, add init.oppo.hypnus.sh
function log2kernel()
{
    echo "hypnus: "$1 > /dev/kmsg
}

loop_times=15

if [ -d /data/oppo_log/hypnus ]; then
	rm -rf /data/oppo_log/hypnus/*
fi
if [ -d /data/oppo_log/junk_logs/kernel ]; then
	rm -rf /data/oppo_log/junk_logs/kernel/*
fi
if [ -d /data/oppo_log/junk_logs/ftrace ]; then
	rm -rf /data/oppo_log/junk_logs/ftrace/*
fi

#wait data partition
if [ "$0" != "/data/oppo_lib/init.oppo.hypnus.sh" ]; then
    iter=0
    while [ iter -lt $loop_times ]; do
        #TODO: ext4 for now, need to check fs type of data
        if [ "`stat -f -c '%t' /data/`" == "ef53" ]; then
            break
        fi
        log2kernel "wait for data partition, retry: iter=$iter"
        iter=$(($iter+1));
        sleep 2
    done

    if [ iter -ge $loop_times ]; then
        log2kernel "data partition is not mounted, Installation maybe fail"
    fi

    if [ -f /data/oppo_lib/init.oppo.hypnus.sh ]; then
        /system/bin/sh /data/oppo_lib/init.oppo.hypnus.sh
        log2kernel "run /data/oppo_lib/init.oppo.hypnus.sh"
        exit 0
    fi
else
        log2kernel "load sh from data partition"
fi

complete=`getprop sys.boot_completed`
enable=`getprop persist.sys.enable.hypnus`

if [ ! -n "$complete" ] ; then
     complete=0
fi

case "$enable" in
    "1")
        n=0
        while [ n -lt 3 ]; do
            #load data folder module if it is exist
            if [ -f /data/oppo_lib/hypnus.ko ]; then
                insmod /data/oppo_lib/hypnus.ko -f boot_completed=$complete
            else
                insmod /system/lib/modules/hypnus.ko -f boot_completed=$complete
            fi
            if [ $? != 0 ];then
                n=$(($n+1));
                log2kernel "Error: insmod hypnus.ko failed, retry: n=$n"
            else
                log2kernel "module insmod succeed!"
                break
            fi
        done

        if [ n -ge 3 ]; then
             log2kernel "Fail to insmod hypnus module!!"
        fi

        chown system:system /sys/kernel/hypnus/scene_info
        chown system:system /sys/kernel/hypnus/action_info
        chown system:system /sys/kernel/hypnus/view_info
        chown system:system /sys/kernel/hypnus/notification_info
        chown system:system /sys/kernel/hypnus/log_state
       chmod 0664 /sys/kernel/hypnus/notification_info
        chcon u:object_r:sysfs_hypnus:s0 /sys/kernel/hypnus/view_info
        # 1 queuebuffer only; 2 queue and dequeuebuffer;
        setprop persist.report.tid 2
        chown system:system /data/hypnus
        ;;
    "0")
        rmmod hypnus
        log2kernel "Remove hypnus module"
        ;;
esac
#endif /* VENDOR_EDIT */
