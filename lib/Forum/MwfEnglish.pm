#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

package MwfEnglish;
use strict;
use warnings;
our ($VERSION, $lng);
$VERSION = "2.12.0";

#------------------------------------------------------------------------------

# Language module meta information
$lng->{charset}      = "iso-8859-1";
$lng->{author}       = "Markus Wichitill";

#------------------------------------------------------------------------------

# Common strings
$lng->{comUp}        = "Up";
$lng->{comUpTT}      = "Go up a level";
$lng->{comPgTtl}     = "Page";
$lng->{comPgPrev}    = "Previous";
$lng->{comPgPrevTT}  = "Go to previous page";
$lng->{comPgNext}    = "Next";
$lng->{comPgNextTT}  = "Go to next page";
$lng->{comEnabled}   = "enabled";
$lng->{comDisabled}  = "disabled";
$lng->{comHidden}    = "(hidden)";
$lng->{comBoardList} = "Discussions";
$lng->{comBoardGo}   = "Go";
$lng->{comNewUnrd}   = "N/U";
$lng->{comNewUnrdTT} = "New/Unread";
$lng->{comNewRead}   = "N/-";
$lng->{comNewReadTT} = "New/Read";
$lng->{comOldUnrd}   = "-/U";
$lng->{comOldUnrdTT} = "Old/Unread";
$lng->{comOldRead}   = "-/-";
$lng->{comOldReadTT} = "Old/Read";
$lng->{comAnswer}    = "A";
$lng->{comAnswerTT}  = "Answered";
$lng->{comShowNew}   = "New Posts";
$lng->{comShowNewTT} = "Show new posts";
$lng->{comShowUnr}   = "Unread Posts";
$lng->{comShowUnrTT} = "Show unread posts";
$lng->{comShowTdo}   = "Flagged";
$lng->{comShowTdoTT} = "Show posts on your flag list";
$lng->{comFeeds}     = "Feeds";
$lng->{comFeedsTT}   = "Show Atom/RSS feeds";
$lng->{comCaptcha}   = "Please type the six characters from the anti-spam image";
$lng->{comCptImaBot} = "I'm a spambot";
$lng->{comCptImaMan} = "I'm a human";

# Header
$lng->{hdrForum}     = "Forum";
$lng->{hdrForumTT}   = "Forum start page";
$lng->{hdrHomeTT}    = "Associated homepage";
$lng->{hdrOptions}   = "Options";
$lng->{hdrOptionsTT} = "Edit profile and options";
$lng->{hdrHelp}      = "Help";
$lng->{hdrHelpTT}    = "Help and FAQ";
$lng->{hdrSearch}    = "Search";
$lng->{hdrSearchTT}  = "Search posts for keywords";
$lng->{hdrChat}      = "Chat";
$lng->{hdrChatTT}    = "Read and write chat messages";
$lng->{hdrMsgs}      = "Messages";
$lng->{hdrMsgsTT}    = "Read and write private messages";
$lng->{hdrBlog}      = "Blog";
$lng->{hdrBlogTT}    = "Read and write your own blog topics";
$lng->{hdrLogin}     = "Login";
$lng->{hdrLoginTT}   = "Login with username and password";
$lng->{hdrLogout}    = "Logout";
$lng->{hdrLogoutTT}  = "Logout";
$lng->{hdrReg}       = "Register";
$lng->{hdrRegTT}     = "Register user account";
$lng->{hdrNoLogin}   = "Not logged in";
$lng->{hdrWelcome}   = "Welcome,";

# Forum page
$lng->{frmTitle}     = "Forum";
$lng->{frmMarkOld}   = "Mark Old";
$lng->{frmMarkOldTT} = "Mark all posts as old";
$lng->{frmMarkRd}    = "Mark Read";
$lng->{frmMarkRdTT}  = "Mark all posts as read";
$lng->{frmUsers}     = "Users";
$lng->{frmUsersTT}   = "Show user list";
$lng->{frmAttach}    = "Attachments";
$lng->{frmAttachTT}  = "Show attachment list";
$lng->{frmInfo}      = "Info";
$lng->{frmInfoTT}    = "Show forum info";
$lng->{frmNotTtl}    = "Notifications";
$lng->{frmNotDelB}   = "Remove notifications";
$lng->{frmCtgCollap} = "Collapse category";
$lng->{frmCtgExpand} = "Expand category";
$lng->{frmPosts}     = "Posts";
$lng->{frmLastPost}  = "Last Post";
$lng->{frmRegOnly}   = "Registered users only";
$lng->{frmMbrOnly}   = "Board members only";
$lng->{frmNew}       = "new";
$lng->{frmNoBoards}  = "No visible boards.";
$lng->{frmStats}     = "Statistics";
$lng->{frmOnlUsr}    = "Online";
$lng->{frmOnlUsrTT}  = "Users online in the past 5 minutes";
$lng->{frmNewUsr}    = "New";
$lng->{frmNewUsrTT}  = "Users registered in the past 5 days";
$lng->{frmBdayUsr}   = "Birthday";
$lng->{frmBdayUsrTT} = "Users that have their birthday today";
$lng->{frmBlgPst}    = "Blogs";
$lng->{frmBlgPstTT}  = "Blogs with new posts";

# Forum info page
$lng->{fifTitle}     = "Forum";
$lng->{fifGenTtl}    = "General Info";
$lng->{fifGenAdmEml} = "Email Address";
$lng->{fifGenAdmins} = "Administrators";
$lng->{fifGenTZone}  = "Timezone";
$lng->{fifGenVer}    = "Forum Version";
$lng->{fifGenLang}   = "Languages";
$lng->{fifStsTtl}    = "Statistics";
$lng->{fifStsUsrNum} = "Users";
$lng->{fifStsTpcNum} = "Topics";
$lng->{fifStsPstNum} = "Posts";
$lng->{fifStsHitNum} = "Topic Hits";

# New/unread/todo/blog overview page
$lng->{ovwTitleNew}  = "New Posts";
$lng->{ovwTitleUnr}  = "Unread Posts";
$lng->{ovwTitleTdo}  = "Flag List";
$lng->{ovwTitleBlg}  = "New Blog Posts";
$lng->{ovwMarkOld}   = "Mark Old";
$lng->{ovwMarkOldTT} = "Mark all posts as old";
$lng->{ovwMarkRd}    = "Mark Read";
$lng->{ovwMarkRdTT}  = "Mark all posts as read";
$lng->{ovwBlogs}     = "Blogs";
$lng->{ovwBlogsTT}   = "Show new blog posts";
$lng->{ovwTdoRemove} = "Remove";
$lng->{ovwEmpty}     = "No posts found.";
$lng->{ovwMaxCutoff} = "Additional posts have been cut off to limit page length.";

# Board page
$lng->{brdTitle}     = "Board";
$lng->{brdNewTpc}    = "Add Topic";
$lng->{brdNewTpcTT}  = "Add new topic";
$lng->{brdInfo}      = "Info";
$lng->{brdInfoTT}    = "Show board info";
$lng->{brdPrev}      = "Previous";
$lng->{brdPrevTT}    = "Go to previous board";
$lng->{brdNext}      = "Next";
$lng->{brdNextTT}    = "Go to next board";
$lng->{brdTopic}     = "Topic";
$lng->{brdPoster}    = "Poster";
$lng->{brdPosts}     = "Posts";
$lng->{brdLastPost}  = "Last Post";
$lng->{brdLocked}    = "L";
$lng->{brdLockedTT}  = "Locked";
$lng->{brdInvis}     = "I";
$lng->{brdInvisTT}   = "Invisible";
$lng->{brdPoll}      = "P";
$lng->{brdPollTT}    = "Poll";
$lng->{brdNew}       = "new";
$lng->{brdAdmin}     = "Administration";
$lng->{brdAdmRep}    = "Reports";
$lng->{brdAdmRepTT}  = "Show reported posts";
$lng->{brdAdmMbr}    = "Members";
$lng->{brdAdmMbrTT}  = "Add and remove board members";
$lng->{brdAdmGrp}    = "Groups";
$lng->{brdAdmGrpTT}  = "Edit group permissions";
$lng->{brdAdmOpt}    = "Options";
$lng->{brdAdmOptTT}  = "Edit board options";
$lng->{brdAdmDel}    = "Delete";
$lng->{brdAdmDelTT}  = "Delete board";
$lng->{brdBoardFeed} = "Board Feed";
# TUSK begin adding num views to topic
$lng->{brdPostViews} = "Views";
# TUSK end

# Board info page
$lng->{bifTitle}     = "Board";
$lng->{bifOptTtl}    = "Options";
$lng->{bifOptDesc}   = "Description";
$lng->{bifOptLock}   = "Locking";
$lng->{bifOptLockT}  = "days after last post, topics will be locked";
$lng->{bifOptExp}    = "Expiration";
$lng->{bifOptExpT}   = "days after last post, topics will be deleted";
$lng->{bifOptAttc}   = "Attachments";
$lng->{bifOptAttcY}  = "File attachments are enabled";
$lng->{bifOptAttcN}  = "File attachments are disabled";
$lng->{bifOptAprv}   = "Moderation";
$lng->{bifOptAprvY}  = "Posts have to be approved to be visible";
$lng->{bifOptAprvN}  = "Posts don't have to be approved to be visible";
$lng->{bifOptPriv}   = "Read Access";
$lng->{bifOptPriv0}  = "All users can see board";
$lng->{bifOptPriv1}  = "Only admins/moderators/members can see board";
$lng->{bifOptPriv2}  = "Only registered users can see board";
$lng->{bifOptAnnc}   = "Write Access";
$lng->{bifOptAnnc0}  = "All users can post";
$lng->{bifOptAnnc1}  = "Only admins/moderators/members can post";
$lng->{bifOptAnnc2}  = "Only admins/moderators/members can start topics, all users can reply";
$lng->{bifOptUnrg}   = "Registration";
$lng->{bifOptUnrgY}  = "Posting doesn't require registration";
$lng->{bifOptUnrgN}  = "Posting requires registration";
$lng->{bifOptAnon}   = "Anonymous";
$lng->{bifOptAnonY}  = "Posts are anonymous";
$lng->{bifOptAnonN}  = "Posts are not anonymous";
$lng->{bifOptFlat}   = "Threading";
$lng->{bifOptFlatY}  = "Topics are non-threaded";
$lng->{bifOptFlatN}  = "Topics are threaded";
$lng->{bifAdmsTtl}   = "Moderators";
$lng->{bifMbrsTtl}   = "Members";
$lng->{bifStatTtl}   = "Statistics";
$lng->{bifStatTPst}  = "Posts";
$lng->{bifStatLPst}  = "Last Post";

# Topic page
$lng->{tpcTitle}     = "Topic";
$lng->{tpcBlgTitle}  = "Blog Topic";
$lng->{tpcHits}      = "hits";
$lng->{tpcTag}       = "Tag";
$lng->{tpcTagTT}     = "Set topic tag";
$lng->{tpcSubs}      = "Subscribe";
$lng->{tpcSubsTT}    = "Enable email subscription of topic";
$lng->{tpcPolAdd}    = "Add Poll";
$lng->{tpcPolAddTT}  = "Add poll";
$lng->{tpcPolDel}    = "Delete";
$lng->{tpcPolDelTT}  = "Delete poll";
$lng->{tpcPolLock}   = "Close";
$lng->{tpcPolLockTT} = "Close poll (irreversible)";
$lng->{tpcPolTtl}    = "Poll";
$lng->{tpcPolLocked} = "(Closed)";
$lng->{tpcPolVote}   = "Vote";
$lng->{tpcPolShwRes} = "Show results";
$lng->{tpcRevealTT}  = "Reveal hidden posts";
$lng->{tpcHidTtl}    = "Hidden post";
$lng->{tpcHidIgnore} = "(ignored) ";
$lng->{tpcHidUnappr} = "(unapproved) ";
$lng->{tpcPrev}      = "Previous";
$lng->{tpcPrevTT}    = "Go to previous topic";
$lng->{tpcNext}      = "Next";
$lng->{tpcNextTT}    = "Go to next topic";
$lng->{tpcApprv}     = "Approve";
$lng->{tpcApprvTT}   = "Make post visible to users";
$lng->{tpcReport}    = "Report";
$lng->{tpcReportTT}  = "Report post to moderators";
$lng->{tpcTodo}      = "Flag";
$lng->{tpcTodoTT}    = "Add post to flag list";
$lng->{tpcBranch}    = "Branch";
$lng->{tpcBranchTT}  = "Promote/move/delete branch";
$lng->{tpcEdit}      = "Edit";
$lng->{tpcEditTT}    = "Edit post";
$lng->{tpcDelete}    = "Delete";
$lng->{tpcDeleteTT}  = "Delete post";
$lng->{tpcAttach}    = "Attach";
$lng->{tpcAttachTT}  = "Upload and delete attachments";
$lng->{tpcReply}     = "Reply";
$lng->{tpcReplyTT}   = "Reply to post";
$lng->{tpcQuote}     = "Quote";
$lng->{tpcQuoteTT}   = "Reply to post with quote";
$lng->{tpcBrnCollap} = "Collapse branch";
$lng->{tpcBrnExpand} = "Expand branch";
$lng->{tpcNxtPst}    = "Next";
$lng->{tpcNxtPstTT}  = "Go to next new or unread post";
$lng->{tpcParent}    = "Parent";
$lng->{tpcParentTT}  = "Go to parent post";
$lng->{tpcInvis}     = "I";
$lng->{tpcInvisTT}   = "Invisible";
$lng->{tpcBrdAdmTT}  = "Moderator";
$lng->{tpcAttText}   = "Attachment:";
$lng->{tpcAdmStik}   = "Stick";
$lng->{tpcAdmUnstik} = "Unstick";
$lng->{tpcAdmLock}   = "Lock";
$lng->{tpcAdmUnlock} = "Unlock";
$lng->{tpcAdmMove}   = "Move";
$lng->{tpcAdmMerge}  = "Merge";
$lng->{tpcAdmDelete} = "Delete";
$lng->{tpcBy}        = "By";
$lng->{tpcOn}        = "Date";
$lng->{tpcEdited}    = "Edited";
$lng->{tpcLocked}    = "(locked)";

# Topic subscription page
$lng->{tsbTitle}     = "Topic";
$lng->{tsbSubTtl}    = "Subscribe to Topic";
$lng->{tsbSubT}      = "If you subscribe to this topic, you will get new posts sent to you by email regularly (frequency depends on forum setup).";
$lng->{tsbSubB}      = "Subscribe";
$lng->{tsbUnsubTtl}  = "Unsubscribe Topic";
$lng->{tsbUnsubB}    = "Unsubscribe";

# Add poll page
$lng->{aplTitle}     = "Add Poll";
$lng->{aplPollTitle} = "Poll title or question";
$lng->{aplPollOpts}  = "Options";
$lng->{aplPollMulti} = "Allow multiple votes for different options";
$lng->{aplPollNote}  = "Note: you can't edit polls, and you can't delete them once someone has voted, so please check your poll title and options before adding the poll.";
$lng->{aplPollAddB}  = "Add";

# Add todo page
$lng->{atdTitle}     = "Post";
$lng->{atdTodoTtl}   = "Add Post to Flag List";
$lng->{atdTodoT}     = "If you want to answer or just review this post later without risking to forget it, you can add it to a personal flag list.";
$lng->{atdTodoB}     = "Add";

# Add report page
$lng->{arpTitle}     = "Post";
$lng->{arpRepTtl}    = "Report Post to Administrators and Moderators";
$lng->{arpRepT}      = "If you think this post has content that violates the rules of this forum, you can add it to a list of posts that can be reviewed by all administrators and moderators.";
$lng->{arpRepReason} = "Reason:";
$lng->{arpRepB}      = "Report";

# Report list page
$lng->{repTitle}     = "Reported Posts";
$lng->{repBy}        = "Report By";
$lng->{repOn}        = "On";
$lng->{repTopic}     = "Topic";
$lng->{repPoster}    = "Poster";
$lng->{repPosted}    = "Posted";
$lng->{repDeleteB}   = "Remove report";
$lng->{repEmpty}     = "No reported posts.";

# Reply page
$lng->{rplTitle}     = "Topic";
$lng->{rplBlgTitle}  = "Blog Topic";
$lng->{rplReplyTtl}  = "Post Reply";
$lng->{rplReplyBody} = "Text";
$lng->{rplReplyNtfy} = "Receive reply notifications";
$lng->{rplReplyResp} = "In Response to";
$lng->{rplReplyB}    = "Post";
$lng->{rplReplyPrvB} = "Preview";
$lng->{rplPrvTtl}    = "Preview";
$lng->{rplEmailSbj}  = "Reply Notification";
$lng->{rplEmailFrm}  = "Forum: ";
$lng->{rplEmailBrd}  = "Board: ";
$lng->{rplEmailTpc}  = "Topic: ";
$lng->{rplEmailUsr}  = "User: ";
$lng->{rplEmailUrl}  = "Link: ";
$lng->{rplEmailT2}   = "This is an automatic notification from the forum software.\nPlease do not reply to this email, reply in the forum.";

# New topic page
$lng->{ntpTitle}     = "Board";
$lng->{ntpBlgTitle}  = "Blog";
$lng->{ntpTpcTtl}    = "Post New Topic";
$lng->{ntpTpcSbj}    = "Subject";
$lng->{ntpTpcBody}   = "Text";
$lng->{ntpTpcNtfy}   = "Receive reply notifications";
$lng->{ntpTpcB}      = "Post";
$lng->{ntpTpcPrvB}   = "Preview";
$lng->{ntpPrvTtl}    = "Preview";

# Post edit page
$lng->{eptTitle}     = "Post";
$lng->{eptEditTtl}   = "Edit Post";
$lng->{eptEditSbj}   = "Subject";
$lng->{eptEditBody}  = "Text";
$lng->{eptEditB}     = "Change";
$lng->{eptDeleted}   = "[deleted]";

# Post attachments page
$lng->{attTitle}     = "Post Attachments";
$lng->{attUplTtl}    = "Upload";
$lng->{attUplFile}   = "File (max. size [[bytes]] bytes)";
$lng->{attUplEmbed}  = "Embed (only JPG, PNG and GIF images)";
$lng->{attUplB}      = "Upload";
$lng->{attAttTtl}    = "Attachment";
$lng->{attAttDelB}   = "Delete";
$lng->{attAttTglB}   = "Toggle Embedding";

# User info page
$lng->{uifTitle}     = "User";
$lng->{uifListPst}   = "Posts";
$lng->{uifListPstTT} = "Show posts by this user";
$lng->{uifBlog}      = "Blog";
$lng->{uifBlogTT}    = "Show blog of this user";
$lng->{uifMessage}   = "Send Message";
$lng->{uifMessageTT} = "Send private message to this user";
$lng->{uifIgnore}    = "Ignore";
$lng->{uifIgnoreTT}  = "Ignore this user";
$lng->{uifProfTtl}   = "Profile";
$lng->{uifProfUName} = "Username";
$lng->{uifProfRName} = "Real Name";
$lng->{uifProfBdate} = "Birthday";
$lng->{uifProfEml}   = "Email";
$lng->{uifProfPage}  = "Website";
$lng->{uifProfOccup} = "Occupation";
$lng->{uifProfHobby} = "Hobbies";
$lng->{uifProfLocat} = "Location";
$lng->{uifProfGeoIp} = "IP Country";
$lng->{uifProfIcq}   = "Messengers";
$lng->{uifProfSig}   = "Signature";
$lng->{uifProfAvat}  = "Avatar";
$lng->{uifGrpMbrTtl} = "Group Member";
$lng->{uifBrdAdmTtl} = "Board Moderator";
$lng->{uifBrdMbrTtl} = "Board Member";
$lng->{uifBrdSubTtl} = "Board Subscriptions";
$lng->{uifStatTtl}   = "Statistics";
$lng->{uifStatRank}  = "Rank";
$lng->{uifStatPNum}  = "Posts";
$lng->{uifStatBNum}  = "Blog Topics";
$lng->{uifStatRegTm} = "Registered";
$lng->{uifStatLOTm}  = "Last On";
$lng->{uifStatLRTm}  = "Last Read";
$lng->{uifStatLIp}   = "Last IP";

# User list page
$lng->{uliTitle}     = "User List";
$lng->{uliLfmTtl}    = "List Format";
$lng->{uliLfmSearch} = "Search";
$lng->{uliLfmField}  = "Field";
$lng->{uliLfmSort}   = "Sort";
$lng->{uliLfmSrtNam} = "Username";
$lng->{uliLfmSrtUid} = "User ID";
$lng->{uliLfmSrtFld} = "Field";
$lng->{uliLfmOrder}  = "Order";
$lng->{uliLfmOrdAsc} = "Asc";
$lng->{uliLfmOrdDsc} = "Desc";
$lng->{uliLfmHide}   = "Hide empty";
$lng->{uliLfmListB}  = "List";
$lng->{uliLstName}   = "Username";

# User login page
$lng->{lgiTitle}     = "User";
$lng->{lgiLoginTtl}  = "Login";
$lng->{lgiLoginT}    = "Please enter your username and password to login. If you have forgotten your username, you can type in your account's email address instead. If you don't have an account yet, you can <a href='user_register.pl'>register</a> one. If you just registered an account, you should have received the login information by email.";
$lng->{lgiLoginName} = "Username";
$lng->{lgiLoginPwd}  = "Password";
$lng->{lgiLoginRmbr} = "Remember me on this computer";
$lng->{lgiLoginB}    = "Login";
$lng->{lgiFpwTtl}    = "Forgot Password";
$lng->{lgiFpwT}      = "If you have lost your password, fill in your username and press Request to get a login ticket link sent to your account's email address. If you have forgotten your username, too, you can type in your account's email address instead. Please don't try to use this function repeatedly if the email doesn't arrive immediately, as only the ticket link in the last email will be valid.";
$lng->{lgiFpwB}      = "Request";
$lng->{lgiFpwMlSbj}  = "Forgot Password";
$lng->{lgiFpwMlT}    = "Please visit the following ticket link to login without your password. You may then proceed to change your password to a new one.\n\nFor security reasons, the ticket link is only valid for one use and for a limited time. Also, only the last requested ticket link is valid, should you have requested more than one.";

# User registration page
$lng->{regTitle}     = "User";
$lng->{regRegTtl}    = "Register Account";
$lng->{regRegT}      = "Please enter the following information to register a new account. If you already have an account, you can login on the <a href='user_login.pl'>login page</a>, where you can also request lost passwords.";
$lng->{regRegName}   = "Username";
$lng->{regRegEmail}  = "Email Address (login password will be sent to this address)";
$lng->{regRegEmailV} = "Repeat Email Address";
$lng->{regRegB}      = "Register";
$lng->{regMailSubj}  = "Registration";
$lng->{regMailT}     = "You have registered a forum account.";
$lng->{regMailName}  = "Username: ";
$lng->{regMailPwd}   = "Password: ";
$lng->{regMailT2}    = "After you have logged in using the link or manually using the username and password, please use the \"Options\" menu in the forum to change your password and to adapt your profile and options.";

# User options page
$lng->{uopTitle}     = "User";
$lng->{uopPasswd}    = "Password";
$lng->{uopPasswdTT}  = "Change password";
$lng->{uopEmail}     = "Email";
$lng->{uopEmailTT}   = "Change email address";
$lng->{uopBoards}    = "Boards";
$lng->{uopBoardsTT}  = "Configure board options";
$lng->{uopTopics}    = "Topics";
$lng->{uopTopicsTT}  = "Configure topic options";
$lng->{uopAvatar}    = "Avatar";
$lng->{uopAvatarTT}  = "Select avatar image";
$lng->{uopIgnore}    = "Ignore";
$lng->{uopIgnoreTT}  = "Ignore other users";
$lng->{uopOpenPgp}   = "OpenPGP";
$lng->{uopOpenPgpTT} = "Configure OpenPGP options";
$lng->{uopInfo}      = "Info";
$lng->{uopInfoTT}    = "Show user info";
$lng->{uopProfTtl}   = "Profile";
$lng->{uopProfRName} = "Real Name";
$lng->{uopProfBdate} = "Birthday (YYYY-MM-DD or MM-DD)";
$lng->{uopProfPage}  = "Website";
$lng->{uopProfOccup} = "Occupation";
$lng->{uopProfHobby} = "Hobbies";
$lng->{uopProfLocat} = "Geographic Location";
$lng->{uopProfIcq}   = "Instant Messenger IDs";
$lng->{uopProfSig}   = "Signature";
$lng->{uopProfSigLt} = "(max. 100 characters, 2 lines)";
$lng->{uopPrefTtl}   = "General Options";
$lng->{uopPrefHdEml} = "Hide email address";
$lng->{uopPrefPrivc} = "Hide online status";
$lng->{uopPrefSecLg} = "Limit login to SSL connections (experts only)";
$lng->{uopPrefMnOld} = "Mark posts as old manually";
$lng->{uopPrefNtMsg} = "Receive post reply and message notifications by email, too";
$lng->{uopPrefNt}    = "Receive post reply notifications";
$lng->{uopDispTtl}   = "Display Options";
$lng->{uopDispLang}  = "Language";
$lng->{uopDispTimeZ} = "Timezone";
$lng->{uopDispStyle} = "Style";
$lng->{uopDispFFace} = "Font Face";
$lng->{uopDispFSize} = "Font Size (in pixels, 0 = default)";
$lng->{uopDispIndnt} = "Indent (1-10%, for post threading)";
$lng->{uopDispTpcPP} = "Topics Per Page (0 = use allowed maximum)";
$lng->{uopDispPstPP} = "Posts Per Page (0 = use allowed maximum)";
$lng->{uopDispDescs} = "Show board descriptions";
$lng->{uopDispDeco}  = "Show decorations like user titles, ranks, smileys";
$lng->{uopDispAvas}  = "Show avatars";
$lng->{uopDispImgs}  = "Show embedded images";
$lng->{uopDispSigs}  = "Show signatures";
$lng->{uopDispColl}  = "Collapse topic branches without new/unread posts";
$lng->{uopSubmitTtl} = "Change Options";
$lng->{uopSubmitB}   = "Save";

# User password page
$lng->{pwdTitle}     = "User";
$lng->{pwdChgTtl}    = "Change Password";
$lng->{pwdChgT}      = "Never use the same password for multiple accounts.";
$lng->{pwdChgPwd}    = "Password";
$lng->{pwdChgPwdV}   = "Repeat Password";
$lng->{pwdChgB}      = "Change";

# User email page
$lng->{emlTitle}     = "User";
$lng->{emlChgTtl}    = "Email Address";
$lng->{emlChgT}      = "A new or changed email address will only take effect once you have reacted to the verification email sent to that address.";
$lng->{emlChgAddr}   = "Email Address";
$lng->{emlChgAddrV}  = "Repeat Email Address";
$lng->{emlChgB}      = "Change";
$lng->{emlChgMlSubj} = "Email Address Change";
$lng->{emlChgMlT}    = "You have requested a change of your forum account's email address. To ensure the validity of the address, your account will only be updated once you have visited the following ticket link:";

# User board options page
$lng->{ubdTitle}     = "User";
$lng->{ubdBrdStTtl}  = "Board Options";
$lng->{ubdBrdStSubs} = "Subscribe";
$lng->{ubdBrdStHide} = "Hide";
$lng->{ubdSubmitTtl} = "Change Board Options";
$lng->{ubdChgB}      = "Change";

# User topic options page
$lng->{utpTitle}     = "User";
$lng->{utpTpcStTtl}  = "Topic Options";
$lng->{utpTpcStSubs} = "Subscribe";
$lng->{utpEmpty}     = "No topics with enabled options found.";
$lng->{utpSubmitTtl} = "Change Topic Options";
$lng->{utpChgB}      = "Change";

# Avatar page
$lng->{avaTitle}     = "User";
$lng->{avaUplTtl}    = "Custom Avatar";
$lng->{avaUplFile}   = "JPG/PNG/GIF image, max. size [[bytes]] bytes, dimensions less than or equal to [[width]]x[[height]] pixels, no animation.";
$lng->{avaUplResize} = "Non-conforming images will be automatically reformatted, which may not yield optimal results.";
$lng->{avaUplUplB}   = "Upload";
$lng->{avaUplDelB}   = "Delete";
$lng->{avaGalTtl}    = "Avatar Gallery";
$lng->{avaGalSelB}   = "Select";
$lng->{avaGalDelB}   = "Remove";

# User ignore page
$lng->{uigTitle}     = "User";
$lng->{uigAddT}      = "If you ignore another user, all his private messages to you will be silently discarded, and his public posts will be hidden to you (but you can reveal them if you want).";
$lng->{uigAddTtl}    = "Add User to Ignore List";
$lng->{uigAddUser}   = "Username";
$lng->{uigAddB}      = "Add";
$lng->{uigRemTtl}    = "Remove User from Ignore List";
$lng->{uigRemUser}   = "Username";
$lng->{uigRemB}      = "Remove";

# Group info page
$lng->{griTitle}     = "Group";
$lng->{griMbrTtl}    = "Members";
$lng->{griBrdAdmTtl} = "Board Moderator Permissions";
$lng->{griBrdMbrTtl} = "Board Member Permissions";

# Board membership page
$lng->{mbrTitle}     = "Board";
$lng->{mbrAddTtl}    = "Add Member";
$lng->{mbrAddUser}   = "Username";
$lng->{mbrAddB}      = "Add";
$lng->{mbrRemTtl}    = "Remove Member";
$lng->{mbrRemUser}   = "Username";
$lng->{mbrRemB}      = "Remove";

# Board groups page
$lng->{bgrTitle}     = "Board";
$lng->{bgrPermTtl}   = "Permissions";
$lng->{bgrModerator} = "Moderator";
$lng->{bgrMember}    = "Member";
$lng->{bgrChangeTtl} = "Change Permissions";
$lng->{bgrChangeB}   = "Change";

# Topic tag page
$lng->{ttgTitle}     = "Topic";
$lng->{ttgTagTtl}    = "Tag Topic";
$lng->{ttgTagB}      = "Tag";

# Topic move page
$lng->{mvtTitle}     = "Topic";
$lng->{mvtMovTtl}    = "Move Topic";
$lng->{mvtMovDest}   = "Destination Board";
$lng->{mvtMovB}      = "Move";

# Topic merge page
$lng->{mgtTitle}     = "Topic";
$lng->{mgtMrgTtl}    = "Merge Topics";
$lng->{mgtMrgDest}   = "Destination Topic";
$lng->{mgtMrgDest2}  = "Alternative manual ID input (for older topics or topics in other boards)";
$lng->{mgtMrgB}      = "Merge";

# Branch page
$lng->{brnTitle}     = "Topic Branch";
$lng->{brnPromoTtl}  = "Promote to Topic";
$lng->{brnPromoSbj}  = "Subject";
$lng->{brnPromoBrd}  = "Board";
$lng->{brnPromoLink} = "Add crosslink posts";
$lng->{brnPromoB}    = "Promote";
$lng->{brnProLnkBdy} = "topic branch moved";
$lng->{brnMoveTtl}   = "Move";
$lng->{brnMovePrnt}  = "Parent post ID (can be in different topic, 0 = make first post)";
$lng->{brnMoveB}     = "Move";
$lng->{brnDeleteTtl} = "Delete";
$lng->{brnDeleteB}   = "Delete";

# Search page
$lng->{seaTitle}     = "Search";
$lng->{seaTtl}       = "Criteria";
$lng->{seaAdvOpt}    = "More";
$lng->{seaBoard}     = "Board";
$lng->{seaBoardAll}  = "All boards";
$lng->{seaWords}     = "Keywords";
$lng->{seaWordsChng} = "Some words and/or characters have been changed or removed, since the fulltext index used for performance reasons doesn't support searching for exactly the expression you have typed. This affects words with less than three characters, certain common words and special characters outside of quoted expressions.";
$lng->{seaUser}      = "Poster";
$lng->{seaMinAge}    = "Min. Age";
$lng->{seaMaxAge}    = "Max. Age";
$lng->{seaField}     = "Field";
$lng->{seaFieldBody} = "Text";
$lng->{seaFieldSubj} = "Subject";
$lng->{seaSort}      = "Sort";
$lng->{seaSortTime}  = "Date";
$lng->{seaSortUser}  = "Poster";
$lng->{seaSortRelev} = "Relevance";
$lng->{seaOrder}     = "Order";
$lng->{seaOrderAsc}  = "Asc";
$lng->{seaOrderDesc} = "Desc";
$lng->{seaShowBody}  = "Show Text";
$lng->{seaB}         = "Search";
$lng->{serTopic}     = "Topic";
$lng->{serRelev}     = "Relevance";
$lng->{serPoster}    = "Poster";
$lng->{serPosted}    = "Posted";
$lng->{serNotFound}  = "No matches found.";

# Help page
$lng->{hlpTitle}     = "Help";
$lng->{hlpTxtTtl}    = "Terms and Features";
$lng->{hlpFaqTtl}    = "Frequently Asked Questions";

# Message list page
$lng->{mslTitle}     = "Private Messages";
$lng->{mslSend}      = "Send Message";
$lng->{mslSendTT}    = "Send private message";
$lng->{mslDelAll}    = "Delete All Read";
$lng->{mslDelAllTT}  = "Delete all read and sent private messages";
$lng->{mslInbox}     = "Inbox";
$lng->{mslOutbox}    = "Sent";
$lng->{mslFrom}      = "Sender";
$lng->{mslTo}        = "Recipient";
$lng->{mslDate}      = "Date";
$lng->{mslCommands}  = "Commands";
$lng->{mslDelete}    = "Delete";
$lng->{mslNotFound}  = "No private messages in this box.";
$lng->{mslExpire}    = "Private messages expire after [[days]] days.";

# Add message page
$lng->{msaTitle}     = "Private Message";
$lng->{msaSendTtl}   = "Send Private Message";
$lng->{msaSendRecv}  = "Recipient";
$lng->{msaSendSbj}   = "Subject";
$lng->{msaSendTxt}   = "Message Text";
$lng->{msaSendB}     = "Send";
$lng->{msaSendPrvB}  = "Preview";
$lng->{msaPrvTtl}    = "Preview";
$lng->{msaRefTtl}    = "In Response to";
$lng->{msaEmailSbj}  = "Message Notification";
$lng->{msaEmailTSbj} = "Subject: ";
$lng->{msaEmailUsr}  = "Sender: ";
$lng->{msaEmailUrl}  = "Link: ";
$lng->{msaEmailT2}   = "This is an automatic notification from the forum software.\nPlease do not reply to this email, reply in the forum.";

# Message page
$lng->{mssTitle}     = "Private Message";
$lng->{mssDelete}    = "Delete";
$lng->{mssDeleteTT}  = "Delete message";
$lng->{mssReply}     = "Reply";
$lng->{mssReplyTT}   = "Reply to message";
$lng->{mssQuote}     = "Quote";
$lng->{mssQuoteTT}   = "Reply to message with quote";
$lng->{mssFrom}      = "From";
$lng->{mssTo}        = "To";
$lng->{mssDate}      = "Date";
$lng->{mssSubject}   = "Subject";

# Blog page
$lng->{blgTitle}     = "Blog";
$lng->{blgSubject}   = "Topic";
$lng->{blgDate}      = "Date";
$lng->{blgComment}   = "Comments";
$lng->{blgCommentTT} = "Show and write comments";
$lng->{blgExpire}    = "Blog topics expire after [[days]] days.";

# Chat page
$lng->{chtTitle}     = "Chat";
$lng->{chtRefresh}   = "Refresh";
$lng->{chtRefreshTT} = "Refresh page";
$lng->{chtDelAll}    = "Delete All";
$lng->{chtDelAllTT}  = "Delete all messages";
$lng->{chtAddTtl}    = "Post Message";
$lng->{chtAddB}      = "Post";
$lng->{chtMsgsTtl}   = "Messages";

# Attachment list page
$lng->{aliTitle}     = "Attachment List";
$lng->{aliLfmTtl}    = "List Format";
$lng->{aliLfmSearch} = "Filename";
$lng->{aliLfmBoard}  = "Board";
$lng->{aliLfmSort}   = "Sort";
$lng->{aliLfmSrtFNm} = "Filename";
$lng->{aliLfmSrtUNm} = "Username";
$lng->{aliLfmSrtPTm} = "Date";
$lng->{aliLfmOrder}  = "Order";
$lng->{aliLfmOrdAsc} = "Asc";
$lng->{aliLfmOrdDsc} = "Desc";
$lng->{aliLfmGall}   = "Gallery";
$lng->{aliLfmListB}  = "List";
$lng->{aliLstFile}   = "Filename";
$lng->{aliLstSize}   = "Size";
$lng->{aliLstPost}   = "Post";
$lng->{aliLstUser}   = "User";

# Email subscriptions
$lng->{subSubjBrd}   = "Subscription of board";
$lng->{subSubjTpc}   = "Subscription of topic";
$lng->{subNoReply}   = "This is an automatic subscription email from the forum software.\nPlease do not reply to this email, reply in the forum.";
$lng->{subTopic}     = "Topic: ";
$lng->{subBy}        = "By: ";
$lng->{subOn}        = "Date: ";

# Feeds
$lng->{fedTitle}     = "Feeds";
$lng->{fedAllBoards} = "All public boards";
$lng->{fedAllBlogs}  = "All blogs";

# Bounce detection
$lng->{bncWarning}   = "Warning: your email account is bouncing/rejecting email from this forum. Please rectify this situation, or the forum might have to stop sending email to you.";

# Confirmation
$lng->{cnfTitle}     = "Confirmation";
$lng->{cnfDelAllMsg} = "Do you really want to delete all read messages?";
$lng->{cnfDelAllCht} = "Do you really want to delete all chat messages?";
$lng->{cnfQuestion}  = "Do you really want to delete";
$lng->{cnfQuestion2} = "?";
$lng->{cnfTypeUser}  = "user";
$lng->{cnfTypeGroup} = "group";
$lng->{cnfTypeCateg} = "category";
$lng->{cnfTypeBoard} = "board";
$lng->{cnfTypeTopic} = "topic";
$lng->{cnfTypePoll}  = "poll";
$lng->{cnfTypePost}  = "post";
$lng->{cnfTypeMsg}   = "message";
$lng->{cnfDeleteB}   = "Delete";

# Notification messages
$lng->{notNotify}    = "Notify user (optionally specify reason)";
$lng->{notReason}    = "Reason:";
$lng->{notMsgAdd}    = "[[usrNam]] sent a private <a href='[[msgUrl]]'>message</a>.";
$lng->{notPstAdd}    = "[[usrNam]] replied to a <a href='[[pstUrl]]'>post</a>.";
$lng->{notPstEdt}    = "A moderator edited a <a href='[[pstUrl]]'>post</a>.";
$lng->{notPstDel}    = "A moderator deleted a <a href='[[tpcUrl]]'>post</a>.";
$lng->{notTpcMov}    = "A moderator moved a <a href='[[tpcUrl]]'>topic</a>.";
$lng->{notTpcDel}    = "A moderator deleted a topic titled \"[[tpcSbj]]\".";
$lng->{notTpcMrg}    = "A moderator merged a topic into another <a href='[[tpcUrl]]'>topic</a>.";
$lng->{notEmlReg}    = "Welcome, [[usrNam]]! To enable email-based features, please enter your <a href='[[emlUrl]]'>email address</a>.";

# Top bar messages
$lng->{msgReplyPost} = "Reply posted";
$lng->{msgNewPost}   = "New topic posted";
$lng->{msgPstChange} = "Post changed";
$lng->{msgPstDel}    = "Post deleted";
$lng->{msgPstTpcDel} = "Post and topic deleted";
$lng->{msgPstApprv}  = "Post approved";
$lng->{msgPstAttach} = "Attachment added";
$lng->{msgPstDetach} = "Attachment deleted";
$lng->{msgPstAttTgl} = "Embedding toggled";
$lng->{msgOptChange} = "Options changed";
$lng->{msgPwdChange} = "Password changed";
$lng->{msgAccntReg}  = "Account registered";
$lng->{msgMemberAdd} = "Member added";
$lng->{msgMemberRem} = "Member removed";
$lng->{msgTpcDelete} = "Topic deleted";
$lng->{msgTpcStik}   = "Topic changed to sticky";
$lng->{msgTpcUnstik} = "Topic changed to not sticky";
$lng->{msgTpcLock}   = "Topic locked";
$lng->{msgTpcUnlock} = "Topic unlocked";
$lng->{msgTpcMove}   = "Topic moved";
$lng->{msgTpcMerge}  = "Topics merged";
$lng->{msgBrnPromo}  = "Branch promoted";
$lng->{msgBrnMove}   = "Branch moved";
$lng->{msgBrnDelete} = "Branch deleted";
$lng->{msgPstAddTdo} = "Post added to flag list";
$lng->{msgPstRemTdo} = "Post removed from flag list";
$lng->{msgPstAddRep} = "Post reported";
$lng->{msgPstRemRep} = "Report deleted";
$lng->{msgMarkOld}   = "All posts marked as old";
$lng->{msgMarkRead}  = "All posts marked as read";
$lng->{msgPollAdd}   = "Poll added";
$lng->{msgPollDel}   = "Poll deleted";
$lng->{msgPollLock}  = "Poll closed";
$lng->{msgPollVote}  = "Voted";
$lng->{msgMsgAdd}    = "Private message sent";
$lng->{msgMsgDel}    = "Private message(s) deleted";
$lng->{msgChatAdd}   = "Chat message added";
$lng->{msgChatDel}   = "Chat message(s) deleted";
$lng->{msgIgnoreAdd} = "User added to ignore list";
$lng->{msgIgnoreRem} = "User removed from ignore list";
$lng->{msgCfgChange} = "Forum configuration changed";
$lng->{msgEolTpc}    = "No more topics in that direction";
$lng->{msgTksFgtPwd} = "Email sent";
$lng->{msgTkaFgtPwd} = "Logged in, you may now change your password";
$lng->{msgTkaEmlChg} = "Email address changed";
$lng->{msgCronExec}  = "Cronjob executed";
$lng->{msgTpcTag}    = "Topic tagged";
$lng->{msgTpcSub}    = "Topic subscribed";
$lng->{msgTpcUnsub}  = "Topic unsubscribed";
$lng->{msgTpcUnsAll} = "All topics unsubscribed";
$lng->{msgNotesDel}  = "Notifications deleted";

# Error messages
$lng->{errDefault}   = "[error string missing]";
$lng->{errGeneric}   = "Error";
$lng->{errText}      = "If you think this is a real error, you can inform the administrator. Please include the exact error message and the time of occurrence.";
$lng->{errUser}      = "User Error";
$lng->{errForm}      = "Form Error";
$lng->{errDb}        = "Database Error";
$lng->{errEntry}     = "Database Entry Error";
$lng->{errParam}     = "CGI Parameter Error";
$lng->{errConfig}    = "Configuration Error";
$lng->{errMail}      = "Email Error";
$lng->{errNote}      = "Note";
$lng->{errParamMiss} = "Mandatory parameter is missing.";
$lng->{errCatIdMiss} = "Category ID is missing.";
$lng->{errBrdIdMiss} = "Board ID is missing.";
$lng->{errTpcIdMiss} = "Topic ID is missing.";
$lng->{errUsrIdMiss} = "User ID is missing.";
$lng->{errGrpIdMiss} = "Group ID is missing.";
$lng->{errPstIdMiss} = "Post ID is missing.";
$lng->{errPrtIdMiss} = "Parent post ID is missing.";
$lng->{errMsgIdMiss} = "Message ID is missing.";
$lng->{errTPIdMiss}  = "Topic or post ID is missing.";
$lng->{errCatNotFnd} = "Category doesn't exist.";
$lng->{errBrdNotFnd} = "Board doesn't exist.";
$lng->{errTpcNotFnd} = "Topic doesn't exist.";
$lng->{errPstNotFnd} = "Post doesn't exist.";
$lng->{errPrtNotFnd} = "Parent post doesn't exist.";
$lng->{errMsgNotFnd} = "Message doesn't exist.";
$lng->{errUsrNotFnd} = "User doesn't exist.";
$lng->{errGrpNotFnd} = "Group doesn't exist.";
$lng->{errTktNotFnd} = "Ticket doesn't exist. Tickets expire after two days, and only the most recently requested ticket of a type is valid.";
$lng->{errUsrDel}    = "User account doesn't exist anymore.";
$lng->{errUsrFake}   = "Not a real user account.";
$lng->{errSubEmpty}  = "Subject is empty.";
$lng->{errBdyEmpty}  = "Text is empty.";
$lng->{errNamEmpty}  = "Username is empty.";
$lng->{errPwdEmpty}  = "Password is empty.";
$lng->{errEmlEmpty}  = "Email address is empty.";
$lng->{errEmlInval}  = "Email address is invalid.";
$lng->{errWordEmpty} = "Keywords field is empty.";
$lng->{errNamSize}   = "Username is too short or too long.";
$lng->{errPwdSize}   = "Password is too short or too long.";
$lng->{errEmlSize}   = "Email address is too short or too long.";
$lng->{errNamChar}   = "Username contains illegal characters.";
$lng->{errPwdChar}   = "Password contains illegal characters.";
$lng->{errPwdWrong}  = "Password is wrong.";
$lng->{errReg}       = "You must be registered and logged in to use this function.";
$lng->{errBlocked}   = "Access Denied";
$lng->{errBannedT}   = "You have been banned. Reason:";
$lng->{errBannedT2}  = "Duration: ";
$lng->{errBannedT3}  = "days.";
$lng->{errBlockedT}  = "Your IP address is on the forum's blacklist.";
$lng->{errBlockEmlT} = "Your email domain is on the forum's blacklist.";
$lng->{errAuthz}     = "Access Denied";
$lng->{errAdmin}     = "You don't have the necessary administrative rights.";
$lng->{errCheat}     = "Nice try.";
$lng->{errSubLen}    = "Max. subject length exceeded.";
$lng->{errBdyLen}    = "Max. text length exceeded.";
$lng->{errReadOnly}  = "Only administrators, moderators and members can write to this board.";
$lng->{errModOwnPst} = "You can't vote for/against your own posts.";
$lng->{errTpcLocked} = "Topic is locked, you can't post, edit or vote anymore.";
$lng->{errSubNoText} = "Subject doesn't contain any real text.";
$lng->{errNamGone}   = "This username is already registered.";
$lng->{errEmlGone}   = "This email address is already registered. Only one account per address.";
$lng->{errPwdDiffer} = "Passwords differ.";
$lng->{errEmlDiffer} = "Email addresses differ.";
$lng->{errDupe}      = "This post has already been posted.";
$lng->{errAttName}   = "No file or filename specified.";
$lng->{errAttSize}   = "Upload is missing, was truncated or exceeds maximum allowed size.";
$lng->{errAttDisab}  = "Attachments are disabled.";
$lng->{errPromoTpc}  = "This post is the base post for the whole topic.";
$lng->{errRollback}  = "Transaction rolled back.";
$lng->{errPstEdtTme} = "Posts may only be edited a limited time after their original submission. This time limit has expired.";
$lng->{errNoEmail}   = "User account doesn't have an email address.";
$lng->{errDontEmail} = "Sending of email for your account has been disabled by an administrator. Typical reasons are invalid email addresses, jammed mailboxes and activated autoresponders.";
$lng->{errEditAppr}  = "You can't edit posts in a moderated board anymore once they're approved.";
$lng->{errAdmUsrReg} = "User accounts can only be registered by administrators in this forum.";
$lng->{errTdoDupe}   = "This post is already on the flag list.";
$lng->{errRepOwn}    = "There is no point in reporting your own posts.";
$lng->{errRepDupe}   = "You have already reported this post.";
$lng->{errRepReason} = "Reason field is empty.";
$lng->{errSrcAuth}   = "Request source authentication failed. Either someone tried tricking you into doing something that you didn't want to do, or the authentication values just got their regular refresh. In the latter case, just repeat what you were about to do.";
$lng->{errPolExist}  = "Topic already has a poll.";
$lng->{errPolOneOpt} = "A poll requires at least two options.";
$lng->{errPolNoDel}  = "Only polls without votes can be deleted.";
$lng->{errPolNoOpt}  = "No option selected.";
$lng->{errPolNotFnd} = "Poll doesn't exist.";
$lng->{errPolLocked} = "Poll is closed.";
$lng->{errPolOpNFnd} = "Poll option doesn't exist.";
$lng->{errPolVotedP} = "You have already voted in this poll.";
$lng->{errFeatDisbl} = "This feature is disabled.";
$lng->{errAvaSizeEx} = "Maximum file size exceeded.";
$lng->{errAvaDimens} = "Image must have specified width and height.";
$lng->{errAvaFmtUns} = "File format unsupported or invalid.";
$lng->{errAvaNoAnim} = "Animated images are not allowed.";
$lng->{errRepostTim} = "Flood control enabled. You have to wait [[seconds]] seconds before you can post again.";
$lng->{errCrnEmuBsy} = "The forum is currently busy with maintenance tasks. Please come back later.";
$lng->{errForumLock} = "The forum is currently locked. Please come back later.";
$lng->{errMinRegTim} = "You need to be registered for at least [[hours]] hour(s) before you can use this feature.";
$lng->{errSsnTmeout} = "Login session timed out, is invalid or belongs to someone else. You can avoid this problem by allowing this website to set cookies.";
$lng->{errDbHidden}  = "A database error has occurred and was logged.";
$lng->{errCptTmeOut} = "Anti-spam image timed out, you have [[seconds]] seconds to submit the form.";
$lng->{errCptWrong}  = "Characters from the anti-spam image are not correct. Please try again.";
$lng->{errCptFail}   = "You failed the spambot test.";


#------------------------------------------------------------------------------
# Help

$lng->{help} = "
<h3>Forum</h3>

<p>The forum is the whole installation, and usually contains multiple boards.
You should always enter the forum through a link that ends in forum.pl (not
forum_show.pl) to let the forum know when you start a new session. Otherwise
the forum won't know when to mark posts as new or old.</p>

<h3>User</h3>

<p>A user is anyone who registers an account in the forum. Registration is
usually not required for reading, but only registered users will see
statistics about new/read posts. Users can be granted membership status to
selected boards, enabling them to see private boards and post in read-only
boards.</p>

<h3>Board</h3>

<p>A board contains topics, which in turn contain the posts. Boards can be set 
to be visible to registered users or to administrators, moderators and board 
members only. Boards can be anonymous, meaning the user's ID won't be stored 
with the post (this doesn't guarantee full anonymity from administrators, 
though), and can optionally allow posts by unregistered guests. Announcement 
boards can be read-only, so that they only allow posts by administrators, 
moderators and members, or reply-only, which means that only administrators, 
moderators and members can start new topics, but everybody can reply. Another 
option for boards is moderation. If this option is activated, new posts will be 
invisible to normal users until an administrator or moderator approves them. 
Users can subscribe to a board, which means that they will get all new posts in 
that board by email regularly (frequency depends on forum setup).</p>

<h3>Topic</h3>

<p>A topic, otherwise known as thread, contains all the posts on a specific 
subtopic, that should be named in the topic's subject. Boards have expiration 
values that determine after how many days their topics will expire or get locked 
after their last post has been made. Administrators and moderators can also 
manually lock topics, so that no new messages can be added to them. Users can 
subscribe to a topic, which means that they will get all new posts in that topic 
by email regularly (frequency depends on forum setup).</p>

<h3>Post</h3>

<p>A post is a single public message by a user. It can be either a base post, 
which starts a new topic, or a reply to an existing topic. Posts can be edited 
and deleted, which might be limited to a certain time frame. Posts can be 
added to personal flag lists and can be reported to the administrators and 
moderators in case of rule violations.</p>

<h3>Private Message</h3>

<p>In addition to the public posts, private messages may be enabled in a
forum. Registered users can send each other these messages without knowing the
email addresses of the recipients.</p>

<h3>Administrator</h3>

<p>An administrator can control and edit everything in the forum. A forum can 
have multiple administrators.</p>

<h3>Moderator</h3>

<p>A moderator's powers are limited to the boards he is moderator in. A 
moderator can edit, delete and approve posts by normal users, lock and delete 
topics, add and remove board members and check the list of reported posts. A 
board can have multiple moderators.</p>

<h3>Polls</h3>

<p>The creator of a topic can add a poll to this topic, if this feature is
enabled. Each poll can contain up to 20 options. Registered users can cast one
vote for one option per poll. Polls can't be edited, and can only be deleted
as long as there haven't been any votes.</p>

<h3>Icons</h3>

<table>
<tr><td>
<img src='[[dataPath]]/post_nu.png' alt='N/U'/>
<img src='[[dataPath]]/topic_nu.png' alt='N/U'/>
<img src='[[dataPath]]/board_nu.png' alt='N/U'/>
</td><td>
Yellow icons indicate new posts respectively topics or boards with new posts.
In this forum, 'new' means a post has been added since your last visit. Even
if you have just read it, it is still a new post, and will only be counted as
old on your next visit to the forum.
</td></tr>
<tr><td>
<img src='[[dataPath]]/post_or.png' alt='O/R'/>
<img src='[[dataPath]]/topic_or.png' alt='O/R'/>
<img src='[[dataPath]]/board_or.png' alt='O/R'/>
</td><td>
Checkmarked icons indicate that all posts in a topic or
board have been read. Posts are counted as read once their topic had been on
screen or if they're older than a set number of days. Since new/old and
unread/read are independent concepts in this forum, posts can be new and read
as well as old and unread at the same time.
</td></tr>
<tr><td>
<img src='[[dataPath]]/post_i.png' alt='I'/>
</td><td>
Indicates topics/posts that are invisible to other users, because they 
are waiting for approval by an administrator or moderator.
</td></tr>
<tr><td>
<img src='[[dataPath]]/topic_l.png' alt='L'/>
</td><td>
Indicates that the topic has been locked for some reason and no new
posts (except by administrators and moderators) are allowed.
</td></tr>
</table>

<h3>Markup Tags</h3>

<p>For security reasons, mwForum only supports its own set of markup tags, no 
HTML tags. Available markup tags:</p>

<table>
<tr><td>[b]text[/b]</td>
<td>renders text <b>bold</b></td></tr>
<tr><td>[i]text[/i]</td>
<td>renders text <i>italic</i></td></tr>
<tr><td>[tt]text[/tt]</td>
<td>renders text <tt>nonproportional</tt></td></tr>
<tr><td>[img]address[/img]</td>
<td>embeds a remote image (if the feature is enabled)</td></tr>
<tr><td>[url]address[/url]</td>
<td>links to the address. addresses must be in the form of <i>http://your.address.here</i></td></tr>
<tr><td>[url=address]text[/url]</td>
<td>links to the address with the given text</td></tr>
</table>

<h3>Smileys</h3>

<p>The following emoticons are displayed as images (if the feature is enabled):
:-) :-D ;-) :-( :-o :-P</p>

";

#------------------------------------------------------------------------------
# FAQ

$lng->{faq} = "

<h3>I lost my password, can you send it to me?</h3>

<p>No, the original password isn't stored anywhere for security reasons. But 
on the login page you can request an email with a special login link that is 
valid for a limited time. After using that link to login, you can change your 
password.</p>

<h3>Why this complicated registration via password email?</h3>

<p>This forum has several features that can send you email, e.g. reply 
notifications and board subscriptions. The forum requires you to specify a 
valid email address and only send the required password to that address to 
verify its validity. This is necessary since otherwise a lot of people would 
type in bogus or broken addresses and try to use the email features anyway, 
which would result in hundreds of bounced email/error messages for the 
administrators. This registration process also serves as a double opt-in 
scheme, which prevents the forum from being abused for email-spamming other 
people.</p>

<h3>Do I have to use the logout feature?</h3>

<p>You only need to logout if you are using a computer that is also used by
other non-trusted persons. mwForum stores your user ID and password via
cookies on your computer, and these are removed on logout.</p>

<h3>How do I attach images and other files to posts?</h3>

<p>If attachments are enabled in the forum and the specific board you want to 
post in, first submit your post without the attachment, after that you can 
click the post's Attach button to go to the upload page. Posting and uploading 
is separated this way because uploads can fail for various reasons, and you 
probably don't want to lose your post text when that happens.</p>

";

#------------------------------------------------------------------------------

# Load local string overrides
do 'MwfEnglishLocal.pm';

#------------------------------------------------------------------------------
# Return OK
1;
