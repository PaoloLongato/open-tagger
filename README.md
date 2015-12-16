# open-tagger
Open source Swift app for indoor location.  It uses Bluetooth beacons in fixed locations and roaming iPhones. The general algorithm is designed to be device independent.

# Demo
https://youtu.be/hITAQ6yPZ3I

# How to use it
This app will allow you to use any Bluetooth beacon or iBeacon of your chouce and quickly create indoor fingerprints in any location near to a group of beacons.  For example, in the video above, I have used two beacos to map 3 distinct areas in a relatively small room.  According to their relative positions, I could have mapped a few more areas, in the same room, with just two beacons

1 - Lay out your beacons, ideally high up (e.g. on che cieling) to limit interference with crowds of people.

2 - Several configurations are possible: (e.g. in the corners of a room or lay them down on a "path" up to several meters apart).
3 - If you choose to lay beacons out on corners, start with two corners on the same side of the room and see whether that works well.  If it does not, put one beacon in the middle of the room and / or add beacons on the other corners.
4 - If you choose to lay the beacons out on "path", tey and space them by 10 meters or more.  If it does not work well you probably need more beacons.  Most beacons have a 50 meters range but in reality, past the 10 meters, the signal might be too erratic to be useful (but it all depends on the transmission power - TxPower).
5 - After you chose a tentative configuration, create the areas and tag them as shown in the video.  Test them with the same app.
6 - Delete an area by left-swiping.
7 - Test what configurations works best for you and don't forget to share your insights and applications here.  Thanks you!
8 - Ah.. don't forget to fork and buld the app first.  For (my very own) organisational reasons, I will keep the main code in the branch named "github-master".  This might get merged with the (now empty) main branch in the future.
9 - For deploying a real world app you might want to link open-tagger to a back end and take your time to reproduce the forecasting algorithm on your own consumer facing app.  It should not be too hard.

# Who is it for?
(App / back end) developers who do not want to be (beacon / software) vendor locked, are working with indoor proximity problems and need open source software to customize for any reason.  Once you understand the code, many use cases are possible. For example I have used the code above to make a position sensitive audio guide for museums.  I am in the process of developing an indoor proximity guide for the blind.  So if you are a museum tech person and/ or developer, check this out.  If you are implementing indoor marketing applications this could be a really quick way to get some results because it will allow you to place the beacons once and start adding and deleting areas of interest in a few seconds (what your app will do with position information is up to you).  Also if you are looking for a teqnique that can port to Android, the algorithm used by this app should work (as it is based on relative RSSI and not absolute RSSI numbers).

# Limitations and further improvementes
In theory you could use this application to carry out a full fingerprinting of an indoor space, but a full blown navigation app (that actually works well) would probably require a lot more effort to make it very reactive to real time position changes, capable of sensing heading information (accelerometer, gyroscope, compass) and capable of using simultaneus calibration and navigation tecniques (you probably do not want to spend your week ends constantly re-mapping a shopping centre).  Having said that, I think that the need of re-fingerprinting frequently is not an acute one if you are only interested in proximity to predetermined areas. 

# Contact
paolo [at] dazzlecube.com
