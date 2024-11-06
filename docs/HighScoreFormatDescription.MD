The high scores file is effectively organized like a database table
It contains multiple records. One record per player.
With a name of the player, a year and a score

|Name|Year|Score|
|----|----|-----|
|Tina|2024|10000|

Each record has a fixed length of 26 bytes
20 Bytes are used for the Player name
Consisting of 2 bytes for the year
4 bytes (32 bits) are used to store the score. This means conversion to Petscii is required but it also allows us to save space on disk and compare scores more easily for ranking.
Byte by byte reading can then used so that only one score needs to remain in staging memory while the rest on display can be directly stored in screen memory. The score in staging is to be added to the screen with the other scores shifted according to the value of their score field to make room if the score in staging is in the top 24. Is the score not in the top 24 it should simply be discarded but under no circumstances deleted from disk. With this scheme it is possible to use all remaining blocks on the games disk for high score storage. 

Still, we need to account for the edge case of a disk write not being possible. 
A detection routine for this edge case needs to be implemented.
Ideally, we should be able to distinguish between a full disk and a write protected disk.
If that is not possible then the disk should be assumed to be full and either way an appropriate message is to be displayed to the user.
