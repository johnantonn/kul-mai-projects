# grid-world-mdp
A rational grid world agent formulated as a Markov Decision Process

## Description

The world consists of a 3x5 grid where a rational agent undertakes the task to gather resources by moving one block at a time, in any of the four directions in the grid (north, east, south, west). The agent will only be able to walk into the intended direction 80% of the time, and to either left or right of its original position with an equal probability of 10%. The agent stays in the same position when it bumps into a boundary wall. There are several types of resources and hazards in the grid world. The agent can assign reward values to certain goal states, such as being on a block to collect iron (a common resource), collect diamonds (a rare resource), fall into a pit (damages the agent) or stand in lava (kills the agent). Resources and hazards are modeled as goal states in this MDP.

![Screenshot 2022-01-26 at 4 08 16 PM](https://user-images.githubusercontent.com/8168416/151177965-0e9c9dc2-15bd-40eb-ae2f-9eb92b7948dc.png)


## Goal

The goal of this exercise is to find the optimal policy for the agent using *Policy Iteration*.

## Scope

This exercise is implemented in the context of the *Fundamentals in Artificial Intelligence*, part of KU Leuven's [Advanced Master's in Artificial Intelligence (2021-2022)](https://wms.cs.kuleuven.be/cs/studeren/master-artificial-intelligence).

## References

[Artificial Intelligence: A Modern Approach 4th edition by Stuart Russel and Peter Norvig](http://aima.cs.berkeley.edu/index.html)
