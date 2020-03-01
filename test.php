<?php


$sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
if (socket_connect($sock, '192.168.0.104', 24864)) {
    $welcome = socket_read($sock, 4);
    var_dump($welcome);
    if ($welcome == "\x03WEL") {
        $i=0;
        while (true) {
            $data = str_repeat(chr($i), 93)."\0\0\0";
            socket_write($sock, chr(99).'LED'.$data);
            echo "\r$i      ";
            $i += 20;
            $i &= 0xff;
            usleep(16000);
        }
    }
}