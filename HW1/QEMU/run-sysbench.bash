loops=10
current=0
while [[ $current -lt $loops ]];
do
    echo "Round: $current"

    # CPU-Test-1
    sysbench --test=cpu --cpu-max-prime=20000 --num-threads=4 run | tee cpu-test-1-$current.txt

    # CPU-Test-2
    sysbench --test=cpu --cpu-max-prime=20000 --num-threads=4 run | tee cpu-test-2-$current.txt

    # Memory-Test-1
    sysbench --test=memory --memory-block-size=1K --memory-total-size=100G --num-threads=4 run | tee memory-test-1-$current.txt

    # Memory-Test-2
    sysbench --test=memory --memory-block-size=1M --memory-total-size=1T --num-threads=4 run | tee memory-test-2-$current.txt

    # File Read
    sysbench --num-threads=16 --test=fileio --file-total-size=5G --file-test-mode=rndrd prepare &&
echo3 > /proc/sys/vm/drop_caches
    sysbench --num-threads=16 --test=fileio --file-total-size=5G --file-test-mode=rndrd run | tee fileio-test-rndrd-$current.txt &&
echo3 > /proc/sys/vm/drop_caches
    sysbench --num-threads=16 --test=fileio --file-total-size=5G --file-test-mode=rndrd cleanup &&
echo3 > /proc/sys/vm/drop_caches


    # File Write
    sysbench --num-threads=16 --test=fileio --file-total-size=5G --file-test-mode=rndwr prepare &&
echo 3 > /proc/sys/vm/drop_caches
    sysbench --num-threads=16 --test=fileio --file-total-size=5G --file-test-mode=rndwr run | tee fileio-test-rndwr-$current.txt &&
echo 3 > /proc/sys/vm/drop_caches
    sysbench --num-threads=16 --test=fileio --file-total-size=5G --file-test-mode=rndwr cleanup &&
echo 3 > /proc/sys/vm/drop_caches

    current=$((current+1))
done
