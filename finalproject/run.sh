python create_network.py 20 127.0.0.1 &
pid=$!
sleep 10
python storage_attack.py 4000
kill -s INT $pid
sleep 5
