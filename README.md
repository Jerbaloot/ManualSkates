# ManualSkates
A skating sim where you manually control your feet in order to push yourself around.

## Requirements to Use
The project was built with Godot 4.0.2 and only tested on 4.0.2. If you would like to download and edit the source code, I recommend using Godot 4.0.2 to reduce the likelihood of any unexpected bugs appearing.

Movement is controlled using a gamepad. I used a Nintendo Switch wired controller which is read by my Windows PC as an X-input device. 

## How To
### Running the build
You can find the executables in the exports folder. ```Only the Windows executable has been tested. The html export does not work with my current export settings```

### Movement
Move Skates: Joysticks

Touch Ground: Push-down Joystick

Rotate Skates: Shoulder Bumpers

## Project Description
I like to rollerblade when I get the chance! I had the thought to make a skating sim like those awkward walking sims where you manually control your legs. I initially planned to use two mice instead of a controller. But, there are a couple of problems with that approach:

 1. Mice only sense translational motion, they don't "see" your rotation of the mouse.
 2. Your computer registers only 1 cursor at a time, and I couldn't find any workaround for that. You *could* try to manually read the inputs of the mouse data at the usb port, but I did not want to go down that road.

# Conclusion
This is definitely WIP but I'm shelving this until I have more physical simulations on my belt. The biggest barriers for this simulation are static friction and weight shifting. In real life, a skater shifts weight on their skates to switch between static and kinetic friction. Static friction is somewhat challenging for me to figure out how to simulate.

Also, it is inevitable that this simulation rubberbands and the player is launched to infinity. I haven't figured out the cause exactly. It could be:

 1. Friction is calculated incorrectly because the coordinate system transformations are a little murky. The measured effect would be flipping between extreme directions in velocity.
 2. I am using a very basic euler time-stepping algorithm. It would be better to use some sort of future stepping algorithm like Runge Kutta which uses intermiate steps between time-steps.

I think the latter definitely a cause of the rubber banding because I observed the kinetic energy growing without limit.

## Thank you
Thanks for checking this out! Feel free to leave any feedback or reach out to any of my socials.
