
                                  Fourmilab Cloud Halo

                                          User Guide

As of the latter part of 2020, Second Life is in the process of
migrating from hosting on its own server farm to a “cloud” service
provider.  This process is called the “uplift”, and as it progresses,
regions (simulations) on the main grid are being moved from the
original hosts to the cloud.  This process is intended to be
transparent and, in most cases, has been so far, but you may be curious
whether places you're visiting are on the previous hosts or the cloud
and, if you're a developer, interested in whether any curious behaviour
you observe may correlate with whether a region has been moved to the
cloud.

It is possible to determine whether a region is on an original host or
the cloud by examining the host name of the simulation, but many users
aren't familiar with the arcana of doing so.  Fourmilab Cloud Halo is a
light-hearted attachment which makes it easy to see the hosting status
wherever you happen to visit and alert you to changes when you arrive
in a new region.

To use the Cloud Halo, simply add it to your outfit.  It is an
attachment, worn on the head, which has the form of a halo floating
above it.  The halo is not normally visible.  When you arrive in a
cloud region, a glowing gold halo will appear above your head,
sparkling for a moment, and an ethereal harp will play a few notes.
When you arrive back in a non-cloud region, a dull grey halo will
appear and a “Sad Trombone” will play.  In either case, the halo will
disappear in five seconds (you can configure all of these settings via
a notecard).  The halo appears only when you change to or from the
cloud: it won't distract you as long as you remain in regions of the
same hosting type.

Chat and Configuration Commands

A variety of commands may be submitted on local chat, over default
channel /78.  These commands allow status queries, testing, and
configuration of the attachment's operation.  For complete
documentation, see the User Guide, which is supplied with the product
or may be obtained with the command:
    /78 help
in local chat.  Most of these commands set parameters which control
the operation of the attachment.  After testing your settings with
local chat commands, you'll usually want to place these commands in
the “Script: Configuration” notecard so they'll run automatically
when the script is reset.

                            CLEAR
    Display white space on the local chat window to set off output
    from the previous transcript.

                            HELP
    Give this document to the requester.

                            SCRIPT
    Run a script from the inventory.  All scripts are notecards with
    names that begin with “Script: ”.  The Configuration script is
    run automatically when the attachment resets, but you can create
    and run other scripts as you wish, for example a “Stealth” script
    which suppresses the sound clips usually played upon arrival.
    Scripts are run with the command:
        Script run Script name
    The fully-general Fourmilab Script Processor is used, which
    supports looping, pauses, and nested scripts, but it's unlikely
    you'll need such fancy features here.  The command “Script list"
    will list all scripts in the attachment's inventory.

                            SET
    Set a variety of parameters, as follows.  Settings are usually
    specified in the Configuration notecard so you needn't re-enter
    them every time you reset the script.  In the descriptions below,
    we use the colloquial term “dirt” instead of the awkward
    nomenclature “non-cloud”.

    Set channel n
        Sets the channel on which the attachment listens for commands
        in local chat, which is 78 by default.  This is usually set
        in a Configuration notecard so it will be reset whenever the
        attachment is reset.  If you set it from chat, the channel will
        revert to the default when the script is next reset.

    Set edit on/off
        Since the halo is normally hidden, if you wish to edit it
        (for example to adjust its position relative to the head of
        your avatar), it's not easy to select (you can do it via the
        inventory, but many people don't know that trick).  “Set edit
        on” unconditionally displays the halo so you can select it
        and edit as you wish.  When you're done, “Set edit off” hides
        it as usual.

    Set halo colour <cloud_colour> <dirt_colour>
        Sets, as an RGB vector, the colour of the halo to display upon
        entry to a simulation of the corresponding type.  Defaults are:
            cloud_colour    <1, 0.843137, 0>  (HTML5 gold)
            dirt_colour     <0.5, 0.5, 0.5>   (HTML5 grey)

    Set halo alpha cloud_alpha dirt_alpha
        Sets the transparency of the halo for each venue. If its alpha
        is set to zero, the halo is not shown there.  Defaults are:
            cloud_alpha     1
            dirt_alpha      1
        Setting both alphas to zero disables halos entirely.

    Set halo glow cloud_glow dirt_glow
        Sets the glow factor for each venue.  Defaults are:
            cloud_glow      0.1
            dirt_glow       0

    Set halo time n
        Sets the halo to display for n seconds after appearing.  If n
        is set to zero, the halo will be permanent.  The default is 5
        seconds.

    Set rcwait n
        Sets the delay after arrival in a new region before the region
        arrival actions are taken.  This allows time for the avatar to
        be rendered and attachments to arrive before displaying the
        halo and playing the sound clip.  The default is 2 seconds. If
        set to zero, no delay occurs after the region change is
        reported.

    Set sound "Cloud clip"  "Dirt clip"
        Specifies the sound clips to be played upon arrival in a cloud
        or non-cloud region.  The clips must be present in the
        inventory of the attachment and their names specified exactly
        as in the inventory, including upper and lower case letters and
        spaces. Names including spaces must be quoted.  If a clip is
        specified as "", no sound will be played.  Defaults are:
            cloud           "Harp"
            dirt            "Sad Trombone"

    Set sparkle cloud_on/off  dirt_on/off
        Enables or disables display of the sparkling effect around the
        halo for arrival at each venue.  Defaults are:
            cloud           on
            dirt            off

    Set sparkle time n
        Sets how long the sparkle effect should be displayed.  If set
        to zero, the sparkle will be permanent.  The default is 1
        second.

    Set trace on/off
        Enables or disables output in local chat tracing operation.
        This is generally only of interest to developers.

    Set volume cloud_vol  dirt_vol
        Sets the volume at which the sound clips play.  The volume for
        both is set by default to 0.1, which causes them to be
        localised to near the avatar.  You can set the to a larger
        value, up to 1, if you wish the sound effects to be hear at
        larger distances.

                            STATUS
    Show status.  Sample output is:
        Cloud Halo status:
            Region: Fourmilab
            Grid location: <945, 1211, 0>
            Host name: sim10497.agni.lindenlab.com
            Sim version: 2020-09-11T22:25:15.548903
            Start time: 2020-10-14 23:13:30
            Agents in region: 1
            Script memory.  Free: 31122  Used: 34414 (53%)

                            TEST
    Run a variety of tests.

    Test cloud
        Act as if entering a cloud region from a dirt region.

    Test dirt
        Act as if entering a dirt region from a cloud region.

    Test region
        Simulate arrival in the current region from one of
        the different type.

Acknowledgements

The sound effects are free clips available from:
    https://www.soundeffectsplus.com/

The "Harp" sound when entering a cloud region is derived from "Dream
Harp 06" (SFX 43052410):
    https://www.soundeffectsplus.com/product/dream-harp-06/

All of these effects are © Copyright Finnolia Productions Inc. and
distributed under the Standard License:
    https://www.soundeffectsplus.com/content/license/
The sound clips were prepared for use in this object with the
Audacity sound editor on Linux.

License

This product (software, documents, images, and models) is licensed
under a Creative Commons Attribution-ShareAlike 4.0 International
License.
    http://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode
You are free to copy and redistribute this material in any medium or
format, and to remix, transform, and build upon the material for any
purpose, including commercially.  You must give credit, provide a link
to the license, and indicate if changes were made.  If you remix,
transform, or build upon this material, you must distribute your
contributions under the same license as the original.

The Harp sound effect is licensed as described above in the
Acknowledgements section.
