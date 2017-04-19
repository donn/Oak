# Contribution Guidelines
I would love it if you contribute. There are just two key guidelines for contributing (the last of which is legally binding):

* Please follow the conventions in "Documentation/Conventions.md".
* By submitting a pull request, you represent that you: 1. Have the right to license your contribution to the general public. 2. Agree that your contributions are irrevocably licensed under the Mozilla Public License 2.0 as published by the Mozilla Foundation, including compatibility with secondary licenses. A verbatim copy is included in the root directory of the repository for your convenience.

# What Needs To Be Done
Here are the most important things Oak needs at the moment:
* Pseudo Instruction support. We need li, la, jr and other conveniences. Unlike Oak.js, using a [hacky method](https://github.com/Skyus/Oak.js/blob/master/Sources/RISCV.ts#L915) is not something I want to do here, this needs to be done properly.
* Documentation. Documentation is sparse, and while it is easy to use, Oak's codebase can be quite intimidating still because of the size.

Here are things that while would be nice, are less of a priority:
* Access Control. It is unclear what should be public and what should be private, and which belongs in what module.
* Error Handling. For simulation (and only simulation), Oak should use Swift's error handling. It would be nice to have all the force unwraps gone too, but that will take a while.
* Increasing the IPS count. While Assembly is swift enough, on a release build of Oak only gets about ~5 KIPS on my 2.6GHz machine. Now Oak is not aiming to rival qemu, gem5 or anything speed-wise (Oak's main focus is absolute simplicity), but this is still rather low.
* * Cacheing decodes would be a good start as apps are by definition loopy, but faster decodes are paramount.
* ARM. Oak was initially designed to support ARM, and while college projects have sidetracked that development, until RISC-V becomes stable, the most popular platform would likely continue to be ARM.
* Proper memory map (for RISCV). Oak currently implements an amorphous structure, where data and text are intertwined. Oak does not aim to do anything "magical" and having Oak automatically add instructions to skip data may introduce some complexity.