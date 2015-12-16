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

5 - After you chose a tentative configuration, update BeaconDB.swift with the correct technical details of your beacons. Build the app.  Create the areas and tag them as shown in the video.  Test them with the same app.

6 - Delete an area by left-swiping.

7 - Test what configurations works best for you and don't forget to share your insights and applications here.  Thanks you!

8 - For (my very own) organisational reasons, I will keep the main code in the branch named "github-master".  This might get merged with the (now empty) main branch in the future.

9 - For deploying a real world app you might want to link open-tagger to a back end and take your time to reproduce the forecasting algorithm on your own customer facing app.  It should not be too hard.

# Who is it for?
(App / back end) developers who do not want to be (beacon / software) vendor locked, are working with indoor proximity problems and need open source software to customize.  As it stands, the algorithm does not need blueprints and exhaustive floor surface fingerprinting to deliver proximity information: sparse fingerprints are enough.  The central use case is an app that delivers some sort if output when a user is near a specific fingerprint.  For example I have used the code above to make a position sensitive audio guide for museums and an indoor proximity guide for the blind.  Other classic example would be delivering position sensitive marketing information or "coarse" indor navigation (e.g. room by room or area by area).   Therefore if you are implementing indoor marketing applications or positions sensitive indoor guides this could be an extremely quick way to get some testing done and possibly reimplement the algorithm in a more complex application.  If you are looking for a teqnique that can port to Android, the algorithm used by this app should be a good candidate to reduce the fragmentation problem (as it is based on relative RSSI and not absolute RSSI numbers, so it is antenna independent).

- Museums and galleries
- Shopping centers, malls and large shops
- Public spaces (schools, universities, stations, airports)
- Turist attractions
- Facilities
- ...

# Limitations and further improvementes
You could use this application to carry out a full fingerprinting of an indoor space, but, at the moment, there is no mechanism to associate a fingerprint to an exact coordinate point on a blueprint and there is no mechanism for determining an approximate position should a user be between two or more fingerprints. Furthermore, making a full blown navigation app (that is actually heading sensitive and responsive as the user is walking) might require compass and possibly the implementation of pedestrian dead reckoning.

# Contact
paolo [at] dazzlecube.com
