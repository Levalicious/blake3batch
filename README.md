# blake3batch
OpenCL implementation of batched blake3 calls.

Pretty sure it fails silently sometimes, be careful. I'm not 100% sure how to fix it yet, but I'm working on it.

Mostly copy pasted from the reference C implementation, with a lot of debugging (damn there was a lot of debugging). Has decent performance on my GTX 1060, but since I have no real idea how to benchmark it, y'all are just gonna have to try it out and let me know.


This code is under an MIT license for the parts written by me. Anything else is written by the creators of Blake3, specifically the implementors of the C reference implementation, Samuel Neves and Jack O'Connor. As such, all credit for those parts is to them.
