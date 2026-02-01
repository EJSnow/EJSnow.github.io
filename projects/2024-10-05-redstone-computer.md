---
layout: page.html
title: Redstone Computer (Oct 5, 2024)
created: Oct 5, 2024
lastUpdated: Dec 20, 2025
---

<img alt="My computer as of Sep 13 2025, running Arch Linux" src="/images/redstone-computer.jpg" class="lightboxed">

The Redstone Computer is a Dell OptiPlex 7020 SFF that I got for free last year and turned into a low-end gaming PC/daily driver. I mostly play lightweight and older games, and the computer runs all of them pretty well, typically at a mix of high and ultra settings at 1680x1050 60Hz. The GPU is somewhat bottlenecked due to being in an old PCIe 3.0 system, not to mention thermals are just awful on this computer.

Despite all of that, the computer is somehow quite usable and stable (I haven't had any BSODs in Windows, or major breakage in Linux on this computer). I'm actually impressed with how solid this computer has been. It's also a LOT faster than the laptop I used to use before, which was a slightly older Dell Latitude laptop with a 3rd gen dual-core i7 and only the HD 4000 iGPU. That laptop could barely run Minecraft at playable framerates WITHOUT shaders, and to be honest even Geometry Dash would lag on large extremely detailed levels (and if GD lags then you KNOW it's bad).

## Truly final update I promise (12/17-20/2025)

I was messing around with LACT in Linux and discovered I could undervolt my GPU. (You can't do this in Windows on this card, all adjustments are locked by AMD's Windows drivers. Even in Linux the only adjustment available is core voltage offset.) While the RX 6400 is already ridiculously efficient, I am now able to make it even more so. I initially started with a -65mv undervolt which results in, surprisingly, ~22% lower power draw and no clock speed penalty. Plus temps dropped by a few degrees which when you're in the upper 80s is pretty significant. -65mv wasn't quite stable though. After some further tweaking, I have it stable at -55mv, which is still a slight improvement.

I don't expect to make any further changes to my setup short of building a whole new PC.

## Update (11/18/2025)

It's been over a year since I built this PC! I thought I'd give a little update. The computer is still working well, and no, I still haven't replaced the keyboard or really anything else. I did get a controller with it, and I've been playing Skyrim SE with it, which this computer handles pretty well at Ultra settings, which was a nice surprise.

I have switched to daily-driving Linux^*(Arch btw)*^ now that Windows 10 is EOL and I don't really want to touch Windows 11 more than I have to. I still have Windows 10 installed, though. I was originally planning to delete Windows 10, but I decided not to, so it's still there, just hiding in GRUB. Anyways, Linux has been working quite well for me! It unlocks about 10-15% more performance in games on average (which is insanely impressive to be honest), plus loading times for EVERYTHING are a lot faster than Windows. It's also just a lot nicer to use in general, once it's set up the way I want (which spoiler alert, is both way easier and way more in-depth than Windows).

## Random update (5/26/2025)

The side panel of the case has been modified to give the GPU better ventilation so that it would run cooler. And it does run significantly cooler now. Like, it can actually keep itself from overheating now while being used to as much of its potential as is possible in this system. Before this, under full load it could heat up past 95° which is past the limits for this card. I used a few strategies to keep this from happening *too* much, mainly dropping settings in games and always enabling V-sync to limit framerates to 60 fps. Now, it only gets up to around 87°, so I don't need to do that anymore! Yay!

## Storage upgrade (1/16/2025)

After I got Forza Horizon 4 Ultimate edition, the 500GB SSD I put in originally was nearly full (Wow, I actually filled up a 500GB drive!), so I bought a 1TB HDD. HDD instead of SSD because the HDD was only $38, while a 1TB SATA SSD would have been around $80. At this point, I can't think of any other hardware changes that I can do with this computer, so the next upgrade is likely going to be a new PC (although I may return to a laptop, I'm not sure yet). I do know that after Microsoft kills Windows 10, I'd rather deal with the mess that is Linux than the mess that is Windows 11 (not to mention this computer is incompatible with Windows 11). Although honestly Linux shouldn't be too messy for me, especially since I'm using an AMD GPU.

## Original build (10/5/2024)

This OptiPlex started out with a Core i5-4590, 8 GB of RAM, a 128 GB SSD, and no GPU or Wi-Fi/Bluetooth. Obviously, that won't allow for much gaming, especially since Intel iGPUs of this era are *hot* garbage. So....

* I upgraded the CPU to an Intel Core i7-4790 (non-K, this mobo can't overclock anyway) for the best possible chance of not bottlenecking the GPU I put in this thing... I didn't have to worry about that, since it's doing a fine job of bottlenecking itself lol.
* I replaced the original RAM with a 16 GB Crucial DDR3 kit, just because Windows and games are quite greedy and demand more RAM than the original 8GB kit would have allowed.
* The original 128GB SSD would have filled up pretty much as soon as I got everything set up, so I replaced that with a Crucial 500GB SSD.
* You can't do much gaming on an Intel iGPU from 2013, so I bought a Radeon RX 6400, but unfortunately I had to settle for the loser XFX version as opposed to the Sapphire Pulse RX 6400, which is better in every possible way. The XFX card has a pretty crappy cooler (though the thermals are partly the case's fault), plus the design for mounting the PCIe bracket to the card is awful and requires you to remove the shroud to access two of the screws. And no, I wasn't just going to buy a 3050 6GB, although that is an option. I didn't really want an Nvidia card.
* Finally, I didn't really want to use Ethernet, plus I wanted Bluetooth for my speaker, so I bought a TP-Link Wi-Fi card with Bluetooth. I had to jerry-rig a solution to getting a USB connection for the Bluetooth part. I just got an adapter to turn a USB 2.0 header plug into a regular USB port, and plugged it into one of the USB ports on the back.

To be honest, I think this build is pretty good for what it is. I actually really like SFF computers, especially coming from a laptop. They're a good middle ground between like a mini PC and a typical tower PC. I do not like <i>building</i> in SFF computers (especially Dell Optiplexes/Optiplexen), though. Plus a modern SFF PC would be significantly more expensive than a MicroATX or regular ATX PC, due to the SFF tax. I think my next desktop (whenever that will be) will be a MicroATX build, which to an extent preserves the compactness that I like, but is much easier and cheaper to build in (in fact MicroATX is probably the most cost-effective form factor).

## Pictures

*Note: Click an image to enlarge it.*

<div class="masonry-grid">
  <div class="masonry-item">
    <img alt="All the parts, stacked on top of the computer" src="/images/redstone-computer-1.JPG" loading="lazy" class="lightboxed">

All the parts, stacked on top of the computer

  </div>
  <div class="masonry-item">
    <img alt="Inside the computer after completing all the upgrades" src="/images/redstone-computer-2.JPG" loading="lazy" class="lightboxed">

Inside the computer after completing all the upgrades

  </div>
  <div class="masonry-item">
    <img alt="Installing Windows 10 (this was before I became a Linux user)" src="/images/redstone-computer-3.JPG" loading="lazy" class="lightboxed">

Installing Windows 10 (this was before I became a Linux user)

  </div>
  <div class="masonry-item">
    <img alt="Intial build complete" src="/images/redstone-computer-4.JPG" loading="lazy" class="lightboxed">

Intial build complete

  </div>
  <div class="masonry-item">
    <img alt="The second hard drive, formatted for Windows" src="/images/redstone-computer-6.JPG" loading="lazy" class="lightboxed">

The second hard drive, formatted for Windows

  </div>
  <div class="masonry-item">
    <img alt="The second hard drive before installing it" src="/images/redstone-computer-5.JPG" loading="lazy" class="lightboxed">

The second hard drive before installing it

  </div>
</div>
