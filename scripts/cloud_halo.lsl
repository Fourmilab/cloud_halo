    /*

                       Fourmilab Cloud Halo

                    by John Walker (Fourmilab)

        This is a wearable attachment which shows, via a halo
        and sound effect, whether the wearer is in a region
        running on the Second Life cloud or the legacy server
        farm.

    */

    key owner;                      // Owner / wearer key
    integer commandChannel = 78;    // Command channel in chat
    integer commandH = 0;           // Handle for command channel
    key whoDat = NULL_KEY;          // Avatar who sent command

    string confNotecard = "Script: Configuration";  // Configuration notecard
    string helpFileName = "Fourmilab Cloud Halo User Guide";    // Help file

    //  Simulator venues
    integer SV_CLOUD = 1;           // Cloud (uplifted)
    integer SV_DIRT = -1;           // Non-cloud (legacy Linden Labs co-location hosts)

    integer sim_venue;              // Current simulator venue

    //  Region change

    float rcWait = 2;               // Delay to let things settle after region change
    integer rcWaiting = FALSE;      // Are we waiting after region change ?

    //  Halo

    integer haloed = FALSE;         // Halo shown
    float haloTime = 5;             // How long should we show the halo?  (0 = forever)
    float haloStop;                 // Time to hide the halo
    vector colourCloud = <1, 0.843137, 0>;  // Colour for cloud: HTML5 gold
    vector colourDirt = <0.5, 0.5, 0.5>;    // Colour for dirt
    float alphaCloud = 1;           // Alpha when showing halo for cloud
    float alphaDirt = 1;            // Alpha when showing halo for dirt
    float alphaHide = 0;            // Alpha when hiding halo
    float glowCloud = 0.1;          // Glow when showing halo for cloud
    float glowDirt = 0;             // Glow when showing halo for dirt
    float glowHide = 0;             // Glow when hiding halo

    //  Sparkle effect

    integer ensparkleCloud = TRUE;  // Sparkle on arrival in cloud ?
    integer ensparkleDirt = FALSE;  // Sparkle on arrival in dirt ?
    integer sparkling = FALSE;      // Sparkling particle effect running ?
    float sparkleTime = 1;          // How long should we sparkle ?  (0 = forever)
    float sparkleStop;              // Time to stop sparkling

    //  Sound effects

    string soundCloud = "Harp";     // Sound clip for cloud arrival
    string soundDirt = "Sad Trombone";  // Sound clip for dirt arrival
    float volumeCloud = 0.1;        // Volume for cloud arrival
    float volumeDirt = 0.1;         // Volume for dirt arrival

    integer trace = FALSE;          // Trace operation ?

    //  Script processing

    integer scriptActive = FALSE;   // Are we reading from a script ?
    integer scriptSuspend = FALSE;  // Suspend script execution for asynchronous event

    //  Script Processor messages

    integer LM_SP_INIT = 50;        // Initialise
//  integer LM_SP_RESET = 51;       // Reset script
//  integer LM_SP_STAT = 52;        // Print status
    integer LM_SP_RUN = 53;         // Enqueue script as input source
    integer LM_SP_GET = 54;         // Request next line from script
    integer LM_SP_INPUT = 55;       // Input line from script
    integer LM_SP_EOF = 56;         // Script input at end of file
    integer LM_SP_READY = 57;       // Script ready to read
    integer LM_SP_ERROR = 58;       // Requested operation failed

    //  Command processor messages

    integer LM_CP_COMMAND = 223;    // Process command

    //  tawk  --  Send a message to the interacting user in chat

    tawk(string msg) {
        if (whoDat == NULL_KEY) {
            //  No known sender.  Say in nearby chat.
            llSay(PUBLIC_CHANNEL, msg);
        } else {
            /*  While debugging, when speaking to the owner, use llOwnerSay()
                rather than llRegionSayTo() to avoid the risk of a runaway
                blithering loop triggering the gag which can only be removed
                by a region restart.  */
            if (owner == whoDat) {
                llOwnerSay(msg);
            } else {
                llRegionSayTo(whoDat, PUBLIC_CHANNEL, msg);
            }
        }
    }

    //  isHostCloud  --  Test if hostname is in the cloud

    integer isHostCloud(string hostname) {
        /*  Empirically, this test identifiea a cloud venue,
            at least for the moment.  */
        return llSubStringIndex(hostname, ".secondlife.io") >= 0;
    }

    //  regionVenue  --  Determine simulator venue for current region

    integer regionVenue() {
        integer venue = SV_DIRT;
        string hostname = llGetEnv("simulator_hostname");

        if (trace) {
            tawk("Host name: " + hostname);
        }
        if (isHostCloud(hostname)) {
            venue = SV_CLOUD;
        }
        return venue;
    }

    /*  checkRegion  --  Check venue of current region or
                         simulate region change.  */

    checkRegion(integer which) {
        //  If which is zero, probe region venue
        if (which == 0) {
            which = regionVenue();
            //  If venue unchanged, don't announce
            if (which == sim_venue) {
                return;
            }
            sim_venue = which;              // Save current venue
        }

        /*  The venue has changed (or we're simulating a
            change for testing).  Perform the configured
            announcements of status change.  */

        if (which == SV_CLOUD) {
            //  Entry into a cloud region
            if (trace) {
                tawk("  This is a cloud region.");
            }
            sparkle(SV_CLOUD);
            if ((volumeCloud > 0) && (soundCloud != "")) {
                llPlaySound(soundCloud, volumeCloud);
            }
            halo(SV_CLOUD);
        } else {
            //  Entry into a non-cloud region
            if (trace) {
                tawk("  This is a non-cloud region.");
            }
            sparkle(SV_DIRT);
            if ((volumeDirt > 0) && (soundDirt != "")) {
                llPlaySound(soundDirt, volumeDirt);
            }
            halo(SV_DIRT);
        }
    }

    //  sparkle  --  Start or stop sparkler effect

    sparkle(integer venue) {
        if ((venue != 0) &&
            (((venue == SV_CLOUD) && ensparkleCloud) ||
             ((venue == SV_DIRT) && ensparkleDirt))) {
            vector scol = colourCloud;
            if (venue == SV_DIRT) {
                scol = colourDirt;
            }

            llParticleSystem([
                PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,

                PSYS_SRC_MAX_AGE, 0,
                PSYS_PART_MAX_AGE, 0.2,

                PSYS_SRC_BURST_RATE, 0.05,
                PSYS_SRC_BURST_PART_COUNT, 200,

                PSYS_SRC_BURST_RADIUS, 1,
                PSYS_SRC_BURST_SPEED_MIN, 0.1,
                PSYS_SRC_BURST_SPEED_MAX, 2,
                PSYS_SRC_ACCEL, <0, 0, 20>,

                PSYS_PART_START_COLOR, scol,
                PSYS_PART_END_COLOR, ZERO_VECTOR,

                PSYS_PART_START_ALPHA, 1,
                PSYS_PART_END_ALPHA, 0,

                PSYS_PART_START_SCALE, <0.1, 0.1, 0>,
                PSYS_PART_END_SCALE, <0.01, 0.01, 0>,

                PSYS_PART_FLAGS,
                    PSYS_PART_EMISSIVE_MASK |
                    PSYS_PART_INTERP_COLOR_MASK |
                    PSYS_PART_INTERP_SCALE_MASK |
                    PSYS_PART_FOLLOW_SRC_MASK |
                    PSYS_PART_FOLLOW_VELOCITY_MASK
            ]);
            sparkling = TRUE;
            if (sparkleTime > 0) {
                sparkleStop = llGetTime() + sparkleTime;
                llSetTimerEvent(0.25);
            }
        } else {
            if (sparkling) {
                llParticleSystem([ ]);
                sparkling = FALSE;
                sparkleStop = 0;
            }
        }
    }

    //  halo  --  Show or hide halo

    halo(integer which) {
        if (which != 0) {
            vector colour = colourCloud;
            float alpha = alphaCloud;
            float glow = glowCloud;
            if (which == SV_DIRT) {
                colour = colourDirt;
                alpha = alphaDirt;
                glow = glowDirt;
            }
            llSetLinkPrimitiveParamsFast(LINK_THIS,
                [ PRIM_COLOR, ALL_SIDES, colour, alpha,
                  PRIM_GLOW, ALL_SIDES, glow ]);
            haloed = TRUE;
            if (haloTime > 0) {
                haloStop = llGetTime() + haloTime;
                llSetTimerEvent(0.25);
            }
        } else {
            llSetLinkPrimitiveParamsFast(LINK_THIS,
                [ PRIM_COLOR, ALL_SIDES, colourDirt, alphaHide,
                  PRIM_GLOW, ALL_SIDES, glowHide ]);
            haloed = FALSE;
            haloStop = 0;
        }
    }

    //  UnixTime2List  --  Decode Unix time to [ YYYY, MM, DD, hh, mm, ss ]

    list UnixTime2List(integer vIntDat) {
        if (vIntDat / 2145916800) {
            vIntDat = 2145916800 * (1 | vIntDat >> 31);
        }
        integer vIntYrs = 1970 + ((((vIntDat %= 126230400) >> 31) +
                          vIntDat / 126230400) << 2);
        vIntDat -= 126230400 * (vIntDat >> 31);
        integer vIntDys = vIntDat / 86400;
        list vLstRtn = [ vIntDat % 86400 / 3600,
                         vIntDat % 3600 / 60,
                         vIntDat % 60 ];

        if (789 == vIntDys) {
            vIntYrs += 2;
            vIntDat = 2;
            vIntDys = 29;
        } else {
            vIntYrs += (vIntDys -= (vIntDys > 789)) / 365;
            vIntDys %= 365;
            vIntDys += vIntDat = 1;
            integer vIntTmp;
            while (vIntDys > (vIntTmp = (30 | (vIntDat & 1) ^
                    (vIntDat > 7)) - ((vIntDat == 2) << 1))) {
                vIntDat++;
                vIntDys -= vIntTmp;
            }
        }
        return [ vIntYrs, vIntDat, vIntDys ] + vLstRtn;
    }

    //  Edit integer to two digit string with leading zero

    string lz2(integer n) {
        string sn = (string) n;
        if (n < 10) {
            sn = "0" + sn;
        }
        return sn;
    }

    //  eDate  --  Edit a UnixTime2List() result to ISO 8601 date

    string eDate(list ld) {
        return ((string) llList2Integer(ld, 0)) + "-" +
               lz2(llList2Integer(ld, 1)) + "-" +
               lz2(llList2Integer(ld, 2)) + " " +
               lz2(llList2Integer(ld, 3)) + ":" +
               lz2(llList2Integer(ld, 4)) + ":" +
               lz2(llList2Integer(ld, 5));
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  onOff  --  Parse an on/off parameter

    integer onOff(string param) {
        if (abbrP(param, "on")) {
            return TRUE;
        } else if (abbrP(param, "of")) {
            return FALSE;
        } else {
            return -1;
        }
    }

    /*  fixArgs  --  Transform command arguments into canonical form.
                     All white space within vector and rotation brackets
                     is elided so they will be parsed as single arguments.  */

    string fixArgs(string cmd) {
        cmd = llStringTrim(cmd, STRING_TRIM);
        integer l = llStringLength(cmd);
        integer inbrack = FALSE;
        integer i;
        string fcmd = "";

        for (i = 0; i < l; i++) {
            string c = llGetSubString(cmd, i, i);
            if (inbrack && ((c == ">") || (c == "}"))) {
                inbrack = FALSE;
            }
            if ((c == "<") || (c == "{")) {
                inbrack = TRUE;
            }
            if (!((c == " ") && inbrack)) {
                fcmd += c;
            }
        }
        return fcmd;
    }

    /*  fixQuotes  --   Adjacent arguments bounded by those
                        beginning and ending with quotes (") are
                        concatenated into single arguments with
                        the quotes elided.  */

    list fixQuotes(list args) {
        integer i;
        integer n = llGetListLength(args);

        for (i = 0; i < n; i++) {
            string arg = llList2String(args, i);
            if (llGetSubString(arg, 0, 0) == "\"") {
                /*  Argument begins with a quote.  If it ends with one,
                    strip them and we're done.  */
                if (llGetSubString(arg, -1, -1) == "\"") {
                    string sarg = llDeleteSubString(llGetSubString(arg, 1, -1), -1, -1);
                    args = llListReplaceList(args, [ sarg ], i, i);
                } else {
                    /*  Concatenate arguments until we find one that ends
                        with a quote, then replace the multiple arguments
                        with the concatenation.  */
                    string rarg = llGetSubString(arg, 1, -1);
                    integer looking = TRUE;
                    integer j;

                    for (j = i + 1; looking && (j < n); j++) {
                        string narg = llList2String(args, j);
                        if (llGetSubString(narg, -1, -1) == "\"") {
                            rarg += " " + llGetSubString(narg, 0, -2);
                            looking = FALSE;
                        } else {
                            rarg += " " + narg;
                        }
                    }
                    if (!looking) {
                        args = llListReplaceList(args, [ rarg ], i, j - 1);
                    }
                }
            }
        }
        return args;
    }

    //  configureComplete  --  Perform post-configuration processing

    configureComplete() {
        if (commandH == 0) {
            commandH = llListen(commandChannel, "", NULL_KEY, "");
            tawk("Listening on /" + (string) commandChannel);
        }
        checkRegion(0);             // Check venue of current region
    }

    //  processCommand  --  Process a command

    integer processCommand(key id, string message, integer fromScript) {

        if (id != owner) {
            llRegionSayTo(id, PUBLIC_CHANNEL,
                "You do not have permission to control this object.");
            return FALSE;
        }

        whoDat = id;            // Direct chat output to sender of command

        string prefix = ">> /" + (string) commandChannel + " ";
        if (fromScript) {
            prefix = "++ ";
        }
        tawk(prefix + message);                     // Echo command to sender

        string lmessage = fixArgs(llToLower(message));
        list args = llParseString2List(lmessage, [ " " ], []);    // Command and arguments
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Boot                        Reset the script

        if (abbrP(command, "bo")) {
            llResetScript();

        //  Clear                       Clear chat for debugging

        } else if (abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Help                        Give User Guide notecard to requester

        } else if (abbrP(command, "he")) {
            llGiveInventory(id, helpFileName);      // Give requester the User Guide notecard

        //  Script                      Script commands (handled by Script Processor)

        } else if (abbrP(command, "sc")) {
            llMessageLinked(LINK_THIS, LM_CP_COMMAND,
                llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);

        //  Set

        } else if (abbrP(command, "se")) {
            string svalue = llList2String(args, 2);
            string scvalue = llList2String(args, 3);
            string sdvalue = llList2String(args, 4);

            //  Set channel n

            if (abbrP(sparam, "ch")) {
                integer newch = (integer) svalue;
                if ((newch < 2)) {
                    tawk("Invalid channel " + (string) newch + ".");
                    return FALSE;
                } else {
                    if (commandH != 0) {
                        llListenRemove(commandH);
                    }
                    commandChannel = newch;
                    commandH = llListen(commandChannel, "", NULL_KEY, "");
                    tawk("Listening on /" + (string) commandChannel);
                }

            //  Set edit on/off

            } else if (abbrP(sparam, "ed")) {
                float alpha = alphaHide;
                if (onOff(svalue) == TRUE) {
                    alpha = 1;
                }
                llSetAlpha(alpha, ALL_SIDES);

            //  Set halo

            } else if (abbrP(sparam, "ha")) {

                //  Set halo alpha cloud_alpha dirt_alpha
                if (abbrP(svalue, "al")) {
                    alphaCloud = (float) scvalue;
                    alphaDirt = (float) sdvalue;

                //  Set halo colour cloud<r, g, b> dirt<r, g, b>
                } else if (abbrP(svalue, "co")) {
                    colourCloud = (vector) scvalue;
                    colourDirt = (vector) sdvalue;

                //  Set halo glow cloud_glow dirt_glow
                } else if (abbrP(svalue, "gl")) {
                    glowCloud = (float) scvalue;
                    glowDirt = (float) sdvalue;

                //  Set halo time n
                } else if (abbrP(svalue, "ti")) {
                    haloTime = (float) scvalue;

                } else {
                    tawk("Invalid Set halo.");
                }

            //  Set rcwait n

            } else if (abbrP(sparam, "rc")) {
                rcWait = (float) svalue;

            //  Set sound cloud_clip dirt_clip

            } else if (abbrP(sparam, "so")) {
                args = llParseString2List(llStringTrim(fixArgs(message),
                    STRING_TRIM), [ " " ], [ ]);
                args = fixQuotes(args);
                soundCloud = llList2String(args, 2);
                soundDirt = llList2String(args, 3);

            //  Set sparkle

            } else if (abbrP(sparam, "sp")) {
                //  Set sparkle cloud_on/off dirt_on/off
                integer v = onOff(svalue);
                if (v >= 0) {
                    ensparkleCloud = v;
                    ensparkleDirt = onOff(scvalue);

                //  Set sparkle time n
                } else if (abbrP(svalue, "ti")) {
                    sparkleTime = (float) scvalue;

                } else {
                    tawk("Invalid Set sparkle.");
                }

            //  Set trace on/off

            } else if (abbrP(sparam, "tr")) {
                trace = onOff(svalue);

            //  Set volume cloud_vol dirt_vol

            } else if (abbrP(sparam, "vo")) {
                volumeCloud = (float) svalue;
                volumeDirt = (float) scvalue;

            } else {
                tawk("Invalid.  Set channel/edit/halo/sparkle/trace/volume");
                return FALSE;
            }

        //  Status                              Print status

        } else if (abbrP(command, "st")) {
            vector gridloc = llGetRegionCorner() / 256;
            string hostname = llGetEnv("simulator_hostname");
            string cloudy = "";
            if (isHostCloud(hostname)) {
                cloudy = " (cloud)";
            }
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();

            tawk(llGetScriptName() + " status:\n" +
                 "  Region: " + llGetRegionName() + "\n" +
                 "  Grid location: <" + (string) llRound(gridloc.x) + ", " +
                        (string) llRound(gridloc.y) + ", 0>\n" +
                 "  Host name: " + hostname + cloudy + "\n" +
                 "  Sim version: " + llGetEnv("sim_version") + "\n" +
                 "  Start time: " +
                        eDate(UnixTime2List((integer)
                            llGetEnv("region_start_time"))) + "\n" +
                 "  Agents in region: " + (string) llGetRegionAgentCount() + "\n" +
                 "  Script memory.  Free: " + (string) mFree +
                 "  Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)"
                );

        //  Test                                Run various tests

        } else if (abbrP(command, "te")) {
            if (argn > 1) {
                //  Test cloud                  Simulate arrival in cloud
                if (abbrP(sparam, "cl")) {
                    checkRegion(1);

                //  Test dirt                   Simulate arrival in dirt
                } else if (abbrP(sparam, "di")) {
                    checkRegion(-1);

                //  Test region                 Simulate check on arrival in region
                } else if (abbrP(sparam, "re")) {
                    checkRegion(0);

                } else {
                    tawk("Unknown Test item.  Valid: cloud/dirt/region");
                }
            }
        } else {
            tawk("Unknown command.  Use /" + (string) commandChannel +
                 " Help for information.");
        }
        return TRUE;
    }

    default {

        on_rez(integer start_param) {
            llResetScript();
        }

        state_entry() {
            whoDat = owner = llGetOwner();

            //  If a configuration notecard exists, run it now

            if (llGetInventoryKey(confNotecard) != NULL_KEY) {
                llMessageLinked(LINK_THIS, LM_SP_RUN,
                    confNotecard, whoDat);
            } else {
                configureComplete();
            }
        }

        //  Process changes

        changed(integer what) {
            if (what & CHANGED_REGION) {
                if (rcWait > 0) {
                    /*  If rcWait is set nonzero, terminate any
                        in-progress sparkle or halo display, then
                        set the timer to perform the new region
                        check when it expires.  */
                    if (sparkling) {
                        sparkle(FALSE);
                    }
                    if (haloed) {
                        halo(0);
                    }
                    rcWaiting = TRUE;
                    llSetTimerEvent(rcWait);
                } else {
                    checkRegion(0);
                }
            }
        }

        //  Attachment to or detachment from an avatar

        attach(key attachedAgent) {
            if (attachedAgent != NULL_KEY) {
                whoDat = attachedAgent;
                if (commandH == 0) {
                    commandH = llListen(commandChannel, "", NULL_KEY, "");
                    tawk("Listening on /" + (string) commandChannel);
                }
            } else {
                llListenRemove(commandH);
                commandH = 0;
            }
        }

        /*  The listen event handler processes messages from
            our chat control channel.  */

        listen(integer channel, string name, key id, string message) {
            processCommand(id, message, FALSE);
        }

        /*  The timer is used to hide the halo and particle
            effects once their stop times are reached.  When
            neither effect is running, we stop the timer.

            We also use the timer to wait for things to settle
            after a region change before taking action when
            rcWait it set nonzero.  */

        timer() {
            if (rcWaiting) {
                rcWaiting = FALSE;
                llSetTimerEvent(0);
                checkRegion(0);
            } else {
                float t = llGetTime();
                if (sparkling && (sparkleTime > 0) && (t >= sparkleStop)) {
                    sparkle(FALSE);
                }
                if (haloed && (haloTime > 0) && (t >= haloStop)) {
                    halo(0);
                }
                if (((!haloed) || (haloTime == 0)) &&
                    ((!sparkling) || (sparkleTime == 0))) {
                    llSetTimerEvent(0);
                }
            }
        }

        /*  The link_message() event receives commands from other scripts
            and passes them on to the script processing functions within
            this script.  */

        link_message(integer sender, integer num, string str, key id) {

            //  Script Processor Messages

            //  LM_SP_READY (57): Script ready to read

            if (num == LM_SP_READY) {
                scriptActive = TRUE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", id);  // Get the first line

            //  LM_SP_INPUT (55): Next executable line from script

            } else if (num == LM_SP_INPUT) {
                if (str != "") {                // Process only if not hard EOF
                    scriptSuspend = FALSE;
                    integer stat = processCommand(id, str, TRUE); // Some commands set scriptSuspend
                    if (stat) {
                        if (!scriptSuspend) {
                            llMessageLinked(LINK_THIS, LM_SP_GET, "", id);
                        }
                    } else {
                        //  Error in script command.  Abort script input.
                        scriptActive = scriptSuspend = FALSE;
                        llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
                        tawk("Script terminated.");
                    }
                }

            //  LM_SP_EOF (56): End of file reading from script

            } else if (num == LM_SP_EOF) {
                scriptActive = FALSE;           // Mark script input complete
                configureComplete();

            //  LM_SP_ERROR (58): Error processing script request

            } else if (num == LM_SP_ERROR) {
                llRegionSayTo(id, PUBLIC_CHANNEL, "Script error: " + str);
                scriptActive = scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
            }
        }
    }
