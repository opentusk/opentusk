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

package MwfGerman;
use strict;
use warnings;
our ($VERSION, $lng);
$VERSION = "2.12.0";

#------------------------------------------------------------------------------

# Default to English for missing strings
no warnings qw(once);
require Forum::MwfEnglish;
%$lng = %$MwfEnglish::lng;

#------------------------------------------------------------------------------

# Language module meta information
$lng->{charset}      = "iso-8859-1";
$lng->{author}       = "Markus Wichitill";

#------------------------------------------------------------------------------

# Common strings
$lng->{comUp}        = "Hoch";
$lng->{comUpTT}      = "Zu höherer Ebene gehen";
$lng->{comPgTtl}     = "Seite";
$lng->{comPgPrev}    = "Zurück";
$lng->{comPgPrevTT}  = "Zu vorheriger Seite gehen";
$lng->{comPgNext}    = "Vor";
$lng->{comPgNextTT}  = "Zu nächster Seite gehen";
$lng->{comEnabled}   = "aktiviert";
$lng->{comDisabled}  = "deaktiviert";
$lng->{comHidden}    = "(versteckt)";
$lng->{comBoardList} = "Forum";
$lng->{comBoardGo}   = "OK";
$lng->{comNewUnrd}   = "N/U";
$lng->{comNewUnrdTT} = "Neu/Ungelesen";
$lng->{comNewRead}   = "N/-";
$lng->{comNewReadTT} = "Neu/Gelesen";
$lng->{comOldUnrd}   = "-/U";
$lng->{comOldUnrdTT} = "Alt/Ungelesen";
$lng->{comOldRead}   = "-/-";
$lng->{comOldReadTT} = "Alt/Gelesen";
$lng->{comAnswer}    = "B";
$lng->{comAnswerTT}  = "Beantwortet";
$lng->{comShowNew}   = "Neues";
$lng->{comShowNewTT} = "Neue Nachrichten anzeigen";
$lng->{comShowUnr}   = "Ungelesenes";
$lng->{comShowUnrTT} = "Ungelesene Nachrichten anzeigen";
$lng->{comShowTdo}   = "Merkliste";
$lng->{comShowTdoTT} = "Nachrichten auf Merkliste anzeigen";
$lng->{comFeeds}     = "Feeds";
$lng->{comFeedsTT}   = "Atom/RSS-Feeds anzeigen";
$lng->{comCaptcha}   = "Bitte tippen Sie die sechs Buchstaben vom Anti-Spam-Bild ab";
$lng->{comCptImaBot} = "Ich bin ein Spambot";
$lng->{comCptImaMan} = "Ich bin ein Mensch";

# Header
$lng->{hdrForum}     = "Forum";
$lng->{hdrForumTT}   = "Forums-Startseite";
$lng->{hdrHomeTT}    = "Zum Forum gehörige Homepage";
$lng->{hdrOptions}   = "Optionen";
$lng->{hdrOptionsTT} = "Profil und Optionen ändern";
$lng->{hdrHelp}      = "Hilfe";
$lng->{hdrHelpTT}    = "Hilfe und FAQ";
$lng->{hdrSearch}    = "Suche";
$lng->{hdrSearchTT}  = "Nachrichten durchsuchen";
$lng->{hdrChat}      = "Chat";
$lng->{hdrChatTT}    = "Chat-Nachrichten lesen und schreiben";
$lng->{hdrMsgs}      = "Nachrichten";
$lng->{hdrMsgsTT}    = "Private Nachrichten lesen und schreiben";
$lng->{hdrBlog}      = "Blog";
$lng->{hdrBlogTT}    = "Eigene Blog-Themen lesen und schreiben";
$lng->{hdrLogin}     = "Anmelden";
$lng->{hdrLoginTT}   = "Mit Benutzername und Passwort anmelden";
$lng->{hdrLogout}    = "Abmelden";
$lng->{hdrLogoutTT}  = "Abmelden";
$lng->{hdrReg}       = "Registrieren";
$lng->{hdrRegTT}     = "Benutzerkonto registrieren";
$lng->{hdrNoLogin}   = "Nicht angemeldet";
$lng->{hdrWelcome}   = "Willkommen,";

# Forum page
$lng->{frmTitle}     = "Forum";
$lng->{frmMarkOld}   = "Alles alt";
$lng->{frmMarkOldTT} = "Alle Nachrichten als alt markieren";
$lng->{frmMarkRd}    = "Alles gelesen";
$lng->{frmMarkRdTT}  = "Alle Nachrichten als gelesen markieren";
$lng->{frmUsers}     = "Benutzer";
$lng->{frmUsersTT}   = "Benutzerliste anzeigen";
$lng->{frmAttach}    = "Dateien";
$lng->{frmAttachTT}  = "Dateianhangsliste anzeigen";
$lng->{frmInfo}      = "Info";
$lng->{frmInfoTT}    = "Foruminfo anzeigen";
$lng->{frmNotTtl}    = "Benachrichtigungen";
$lng->{frmNotDelB}   = "Benachrichtigungen entfernen";
$lng->{frmCtgCollap} = "Kategorie zusammenklappen";
$lng->{frmCtgExpand} = "Kategorie expandieren";
$lng->{frmPosts}     = "Nachrichten";
$lng->{frmLastPost}  = "Neueste";
$lng->{frmRegOnly}   = "Nur für registrierte Benutzer";
$lng->{frmMbrOnly}   = "Nur für Brettmitglieder";
$lng->{frmNew}       = "neu";
$lng->{frmNoBoards}  = "Keine sichtbaren Bretter.";
$lng->{frmStats}     = "Statistiken";
$lng->{frmOnlUsr}    = "Online";
$lng->{frmOnlUsrTT}  = "Benutzer online während der letzten 5 Minuten";
$lng->{frmNewUsr}    = "Neu";
$lng->{frmNewUsrTT}  = "Benutzer registriert während der letzten 5 Tage";
$lng->{frmBdayUsr}   = "Geburtstag";
$lng->{frmBdayUsrTT} = "Benutzer die heute Geburtstag haben";
$lng->{frmBlgPst}    = "Blogs";
$lng->{frmBlgPstTT}  = "Blogs mit neuen Nachrichten";

# Forum info page
$lng->{fifTitle}     = "Forum";
$lng->{fifGenTtl}    = "Allgemeine Info";
$lng->{fifGenAdmEml} = "Emailadresse";
$lng->{fifGenAdmins} = "Administratoren";
$lng->{fifGenTZone}  = "Zeitzone";
$lng->{fifGenVer}    = "Forumsversion";
$lng->{fifGenLang}   = "Sprachen";
$lng->{fifStsTtl}    = "Statistik";
$lng->{fifStsUsrNum} = "Benutzer";
$lng->{fifStsTpcNum} = "Themen";
$lng->{fifStsPstNum} = "Nachrichten";
$lng->{fifStsHitNum} = "Themenzugriffe";

# New/unread/todo/blog overview page
$lng->{ovwTitleNew}  = "Neue Nachrichten";
$lng->{ovwTitleUnr}  = "Ungelesene Nachrichten";
$lng->{ovwTitleTdo}  = "Merkliste";
$lng->{ovwTitleBlg}  = "Neue Blog-Nachrichten";
$lng->{ovwMarkOld}   = "Alles alt";
$lng->{ovwMarkOldTT} = "Alle Nachrichten als alt markieren";
$lng->{ovwMarkRd}    = "Alles gelesen";
$lng->{ovwMarkRdTT}  = "Alle Nachrichten als gelesen markieren";
$lng->{ovwBlogs}     = "Blogs";
$lng->{ovwBlogsTT}   = "Neue Blog-Nachrichten anzeigen";
$lng->{ovwTdoRemove} = "Entfernen";
$lng->{ovwEmpty}     = "Keine Nachrichten vorhanden.";
$lng->{ovwMaxCutoff} = "Weitere Nachrichten wurden ausgelassen, um die Seitenlänge zu begrenzen.";

# Board page
$lng->{brdTitle}     = "Brett";
$lng->{brdNewTpc}    = "Thema hinzufügen";
$lng->{brdNewTpcTT}  = "Neues Thema hinzufügen";
$lng->{brdInfo}      = "Info";
$lng->{brdInfoTT}    = "Brettinfo anzeigen";
$lng->{brdPrev}      = "Zurück";
$lng->{brdPrevTT}    = "Zu vorherigem Brett gehen";
$lng->{brdNext}      = "Vor";
$lng->{brdNextTT}    = "Zu nächstem Brett gehen";
$lng->{brdTopic}     = "Thema";
$lng->{brdPoster}    = "Schreiber";
$lng->{brdPosts}     = "Nachrichten";
$lng->{brdLastPost}  = "Neueste";
$lng->{brdLocked}    = "L";
$lng->{brdLockedTT}  = "Gesperrt";
$lng->{brdInvis}     = "I";
$lng->{brdInvisTT}   = "Unsichtbar";
$lng->{brdPoll}      = "P";
$lng->{brdPollTT}    = "Umfrage";
$lng->{brdNew}       = "neu";
$lng->{brdAdmin}     = "Administration";
$lng->{brdAdmRep}    = "Beschwerden";
$lng->{brdAdmRepTT}  = "Beschwerden über Nachrichten anzeigen";
$lng->{brdAdmMbr}    = "Mitglieder";
$lng->{brdAdmMbrTT}  = "Brettmitglieder hinzufügen und entfernen";
$lng->{brdAdmGrp}    = "Gruppen";
$lng->{brdAdmGrpTT}  = "Gruppenbefugnisse editieren";
$lng->{brdAdmOpt}    = "Optionen";
$lng->{brdAdmOptTT}  = "Brettoptionen editieren";
$lng->{brdAdmDel}    = "Löschen";
$lng->{brdAdmDelTT}  = "Brett löschen";
$lng->{brdBoardFeed} = "Brett-Feed";

# Board info page
$lng->{bifTitle}     = "Brett";
$lng->{bifOptTtl}    = "Optionen";
$lng->{bifOptDesc}   = "Beschreibung";
$lng->{bifOptLock}   = "Sperrzeit";
$lng->{bifOptLockT}  = "Tage nach letzter Nachricht werden Themen gesperrt";
$lng->{bifOptExp}    = "Haltezeit";
$lng->{bifOptExpT}   = "Tage nach letzter Nachricht werden Themen gelöscht";
$lng->{bifOptAttc}   = "Anhänge";
$lng->{bifOptAttcY}  = "Dateianhänge sind aktiviert";
$lng->{bifOptAttcN}  = "Dateianhänge sind nicht aktiviert";
$lng->{bifOptAprv}   = "Moderation";
$lng->{bifOptAprvY}  = "Nachrichten müssen bestätigt werden, um sichtbar zu sein";
$lng->{bifOptAprvN}  = "Nachrichten müssen nicht bestätigt werden, um sichtbar zu sein";
$lng->{bifOptPriv}   = "Lesezugriff";
$lng->{bifOptPriv0}  = "Alle Benutzer können das Brett sehen";
$lng->{bifOptPriv1}  = "Nur Admins/Moderatoren/Mitglieder können das Brett sehen";
$lng->{bifOptPriv2}  = "Nur registrierte Benutzer können das Brett sehen";
$lng->{bifOptAnnc}   = "Schreibzugriff";
$lng->{bifOptAnnc0}  = "Alle Benutzer können schreiben";
$lng->{bifOptAnnc1}  = "Nur Admins/Moderatoren/Mitglieder können schreiben";
$lng->{bifOptAnnc2}  = "Admins/Moderatoren/Mitglieder können neue Themen starten, alle können antworten";
$lng->{bifOptUnrg}   = "Registrierung";
$lng->{bifOptUnrgY}  = "Schreiben ist auch ohne Registrierung möglich";
$lng->{bifOptUnrgN}  = "Schreiben ist nur mit Registrierung möglich";
$lng->{bifOptAnon}   = "Anonym";
$lng->{bifOptAnonY}  = "Nachrichten sind anonym";
$lng->{bifOptAnonN}  = "Nachrichten sind nicht anonym";
$lng->{bifOptFlat}   = "Struktur";
$lng->{bifOptFlatY}  = "Nachrichten werden sequentiell angeordnet";
$lng->{bifOptFlatN}  = "Nachrichten werden in einer Baumstruktur angeordnet";
$lng->{bifAdmsTtl}   = "Moderatoren";
$lng->{bifMbrsTtl}   = "Mitglieder";
$lng->{bifStatTtl}   = "Statistik";
$lng->{bifStatTPst}  = "Anzahl Nachrichten";
$lng->{bifStatLPst}  = "Neueste Nachricht";

# Topic page
$lng->{tpcTitle}     = "Thema";
$lng->{tpcBlgTitle}  = "Blog-Thema";
$lng->{tpcHits}      = "Hits";
$lng->{tpcTag}       = "Taggen";
$lng->{tpcTagTT}     = "Thema-Tag setzen";
$lng->{tpcSubs}      = "Abonnieren";
$lng->{tpcSubsTT}    = "Thema per Email abonnieren";
$lng->{tpcPolAdd}    = "Umfrage hinzufügen";
$lng->{tpcPolAddTT}  = "Umfrage hinzufügen";
$lng->{tpcPolDel}    = "Löschen";
$lng->{tpcPolDelTT}  = "Umfrage löschen";
$lng->{tpcPolLock}   = "Beenden";
$lng->{tpcPolLockTT} = "Umfrage beenden (irreversibel)";
$lng->{tpcPolTtl}    = "Umfrage";
$lng->{tpcPolLocked} = "(beendet)";
$lng->{tpcPolVote}   = "Abstimmen";
$lng->{tpcPolShwRes} = "Ergebnis anzeigen";
$lng->{tpcRevealTT}  = "Unsichtbare Nachrichten aufdecken";
$lng->{tpcHidTtl}    = "Unsichtbare Nachricht";
$lng->{tpcHidIgnore} = "(ignoriert) ";
$lng->{tpcHidUnappr} = "(unbestätigt) ";
$lng->{tpcPrev}      = "Zurück";
$lng->{tpcPrevTT}    = "Zu vorherigem Thema gehen";
$lng->{tpcNext}      = "Vor";
$lng->{tpcNextTT}    = "Zu nächstem Thema gehen";
$lng->{tpcApprv}     = "Bestätigen";
$lng->{tpcApprvTT}   = "Nachricht für alle sichtbar machen";
$lng->{tpcReport}    = "Beschweren";
$lng->{tpcReportTT}  = "Nachricht auf Beschwerdeliste setzen";
$lng->{tpcTodo}      = "Merken";
$lng->{tpcTodoTT}    = "Nachricht auf Merkliste setzen";
$lng->{tpcBranch}    = "Zweig";
$lng->{tpcBranchTT}  = "Zweig umwandeln/verschieben/löschen";
$lng->{tpcEdit}      = "Ändern";
$lng->{tpcEditTT}    = "Nachricht editieren";
$lng->{tpcDelete}    = "Löschen";
$lng->{tpcDeleteTT}  = "Nachricht löschen";
$lng->{tpcAttach}    = "Anhängen";
$lng->{tpcAttachTT}  = "Dateianhänge hochladen und löschen";
$lng->{tpcReply}     = "Antworten";
$lng->{tpcReplyTT}   = "Auf Nachricht antworten";
$lng->{tpcQuote}     = "Zitieren";
$lng->{tpcQuoteTT}   = "Auf Nachricht antworten mit Zitat";
$lng->{tpcBrnCollap} = "Zweig zusammenklappen";
$lng->{tpcBrnExpand} = "Zweig expandieren";
$lng->{tpcNxtPst}    = "Nächste";
$lng->{tpcNxtPstTT}  = "Zu nächster neuer oder ungelesener Nachricht gehen";
$lng->{tpcParent}    = "Basis";
$lng->{tpcParentTT}  = "Zu beantworteter Nachricht gehen";
$lng->{tpcInvis}     = "I";
$lng->{tpcInvisTT}   = "Unsichtbar";
$lng->{tpcBrdAdmTT}  = "Moderator";
$lng->{tpcAttText}   = "Dateianhang:";
$lng->{tpcAdmStik}   = "Fixieren";
$lng->{tpcAdmUnstik} = "Defixieren";
$lng->{tpcAdmLock}   = "Sperren";
$lng->{tpcAdmUnlock} = "Entsperren";
$lng->{tpcAdmMove}   = "Verschieben";
$lng->{tpcAdmMerge}  = "Zusammenlegen";
$lng->{tpcAdmDelete} = "Löschen";
$lng->{tpcBy}        = "Von";
$lng->{tpcOn}        = "Datum";
$lng->{tpcEdited}    = "Editiert";
$lng->{tpcLocked}    = "(gesperrt)";

# Topic subscription page
$lng->{tsbTitle}     = "Thema";
$lng->{tsbSubTtl}    = "Thema abbonieren";
$lng->{tsbSubT}      = "Wenn Sie dieses Thema abonnieren, bekommen Sie neue Nachrichten regelmäßig per Email zugestellt (Häufigkeit hängt von der Forumskonfiguration ab).";
$lng->{tsbSubB}      = "Abonnieren";
$lng->{tsbUnsubTtl}  = "Thema abbestellen";
$lng->{tsbUnsubB}    = "Abbestellen";

# Add poll page
$lng->{aplTitle}     = "Umfrage hinzufügen";
$lng->{aplPollTitle} = "Umfragetitel bzw. Frage";
$lng->{aplPollOpts}  = "Optionen";
$lng->{aplPollMulti} = "Mehrfaches Abstimmen für verschiedene Optionen zulassen";
$lng->{aplPollNote}  = "Hinweis: man kann Umfragen nicht editieren und man kann sie nicht mehr löschen, wenn bereits jemand abgestimmt hat. Daher bitte den Titel und die Optionen vor dem Hinzufügen gründlich überprüfen.";
$lng->{aplPollAddB}  = "Hinzufügen";

# Add todo page
$lng->{atdTitle}     = "Nachricht";
$lng->{atdTodoTtl}   = "Nachricht auf Merkliste setzen";
$lng->{atdTodoT}     = "Falls Sie diese Nachricht später beantworten oder lesen wollen, können Sie sie auf eine persönliche Merkliste setzen, so dass sie nicht in Vergessenheit gerät.";
$lng->{atdTodoB}     = "Hinzufügen";

# Add report page
$lng->{arpTitle}     = "Nachricht";
$lng->{arpRepTtl}    = "Nachricht auf Beschwerdeliste setzen";
$lng->{arpRepT}      = "Falls diese Nachricht einen Inhalt hat, der gegen die Regeln des Forums verstößt, können Sie sie auf eine Beschwerdeliste setzen, die von den Administratoren und Moderatoren eingesehen werden kann.";
$lng->{arpRepReason} = "Begründung:";
$lng->{arpRepB}      = "Beschweren";

# Report list page
$lng->{repTitle}     = "Beschwerdeliste";
$lng->{repBy}        = "Beschwerde von";
$lng->{repOn}        = "Am";
$lng->{repTopic}     = "Thema";
$lng->{repPoster}    = "Schreiber";
$lng->{repPosted}    = "Datum";
$lng->{repDeleteB}   = "Beschwerde entfernen";
$lng->{repEmpty}     = "Keine Nachrichten auf der Beschwerdeliste.";

# Reply page
$lng->{rplTitle}     = "Thema";
$lng->{rplBlgTitle}  = "Blog-Thema";
$lng->{rplReplyTtl}  = "Antwort schreiben";
$lng->{rplReplyBody} = "Text";
$lng->{rplReplyNtfy} = "Antwortbenachrichtigungen empfangen";
$lng->{rplReplyResp} = "Auf Nachricht von";
$lng->{rplReplyB}    = "Schreiben";
$lng->{rplReplyPrvB} = "Vorschau";
$lng->{rplPrvTtl}    = "Vorschau";
$lng->{rplEmailFrm}  = "Forum: ";
$lng->{rplEmailBrd}  = "Brett: ";
$lng->{rplEmailTpc}  = "Thema: ";
$lng->{rplEmailUsr}  = "Schreiber: ";
$lng->{rplEmailUrl}  = "Link: ";
$lng->{rplEmailSbj}  = "Antwortbenachrichtigung";
$lng->{rplEmailT2}   = "Dies ist eine automatische Benachrichtigung der Forumssoftware.\nBitte antworten Sie nicht auf diese Email, sondern im Forum.";

# New topic page
$lng->{ntpTitle}     = "Brett";
$lng->{ntpBlgTitle}  = "Blog";
$lng->{ntpTpcTtl}    = "Neues Thema schreiben";
$lng->{ntpTpcSbj}    = "Betreff";
$lng->{ntpTpcBody}   = "Text";
$lng->{ntpTpcNtfy}   = "Antwortbenachrichtigungen empfangen";
$lng->{ntpTpcB}      = "Schreiben";
$lng->{ntpTpcPrvB}   = "Vorschau";
$lng->{ntpPrvTtl}    = "Vorschau";

# Post edit page
$lng->{eptTitle}     = "Nachricht";
$lng->{eptEditTtl}   = "Nachricht editieren";
$lng->{eptEditSbj}   = "Betreff";
$lng->{eptEditBody}  = "Text";
$lng->{eptEditB}     = "Ändern";
$lng->{eptDeleted}   = "[gelöscht]";

# Post attachments page
$lng->{attTitle}     = "Dateianhänge";
$lng->{attUplTtl}    = "Hochladen";
$lng->{attUplFile}   = "Datei (max. Größe [[bytes]] Bytes)";
$lng->{attUplEmbed}  = "Einbetten (nur für JPG, PNG und GIF-Bilder)";
$lng->{attUplB}      = "Hochladen";
$lng->{attAttTtl}    = "Anhang";
$lng->{attAttDelB}   = "Löschen";
$lng->{attAttTglB}   = "Einbettung umschalten";

# User info page
$lng->{uifTitle}     = "Benutzer";
$lng->{uifListPst}   = "Nachrichten";
$lng->{uifListPstTT} = "Öffentliche Nachrichten dieses Benutzers auflisten";
$lng->{uifBlog}      = "Blog";
$lng->{uifBlogTT}    = "Blog dieses Benutzers anzeigen";
$lng->{uifMessage}   = "Nachricht senden";
$lng->{uifMessageTT} = "Private Nachricht an diesen Benutzer senden";
$lng->{uifIgnore}    = "Ignorieren";
$lng->{uifIgnoreTT}  = "Diesen Benutzer ignorieren";
$lng->{uifProfTtl}   = "Profil";
$lng->{uifProfUName} = "Benutzername";
$lng->{uifProfRName} = "Realname";
$lng->{uifProfBdate} = "Geburtstag";
$lng->{uifProfEml}   = "Emailadresse";
$lng->{uifProfPage}  = "Website";
$lng->{uifProfOccup} = "Tätigkeit";
$lng->{uifProfHobby} = "Hobbies";
$lng->{uifProfLocat} = "Wohnort";
$lng->{uifProfGeoIp} = "IP Land";
$lng->{uifProfIcq}   = "Messenger";
$lng->{uifProfSig}   = "Signatur";
$lng->{uifProfAvat}  = "Avatar";
$lng->{uifGrpMbrTtl} = "Gruppenmitglied";
$lng->{uifBrdAdmTtl} = "Brettmoderator";
$lng->{uifBrdMbrTtl} = "Brettmitglied";
$lng->{uifBrdSubTtl} = "Brettabonnements";
$lng->{uifStatTtl}   = "Statistik";
$lng->{uifStatRank}  = "Rang";
$lng->{uifStatPNum}  = "Nachrichten";
$lng->{uifStatBNum}  = "Blog-Themen";
$lng->{uifStatRegTm} = "Registriert";
$lng->{uifStatLOTm}  = "Zul. anwesend";
$lng->{uifStatLRTm}  = "Zul. gelesen";
$lng->{uifStatLIp}   = "Letzte IP";

# User list page
$lng->{uliTitle}     = "Benutzerliste";
$lng->{uliLfmTtl}    = "Listenformat";
$lng->{uliLfmSearch} = "Suche";
$lng->{uliLfmField}  = "Feld";
$lng->{uliLfmSort}   = "Sort.";
$lng->{uliLfmSrtNam} = "Benutzername";
$lng->{uliLfmSrtUid} = "Benutzer-ID";
$lng->{uliLfmSrtFld} = "Feld";
$lng->{uliLfmOrder}  = "Reihenf.";
$lng->{uliLfmOrdAsc} = "Aufst.";
$lng->{uliLfmOrdDsc} = "Abst.";
$lng->{uliLfmHide}   = "Leere verstecken";
$lng->{uliLfmListB}  = "Auflisten";
$lng->{uliLstName}   = "Benutzername";

# User login page
$lng->{lgiTitle}     = "Benutzer";
$lng->{lgiLoginTtl}  = "Anmelden";
$lng->{lgiLoginT}    = "Bitte geben Sie Benutzernamen und Passwort an. Falls Sie Ihren Benutzernamen vergessen haben, können Sie stattdessen die Emailadresse des Kontos angegeben. Falls Sie noch kein Benutzerkonto besitzen, können Sie eines <a href='user_register.pl'>registrieren</a>. Falls Sie gerade ein Konto registriert haben, sollten die Kontoinformationen per Email gekommen sein.";
$lng->{lgiLoginName} = "Benutzername";
$lng->{lgiLoginPwd}  = "Passwort";
$lng->{lgiLoginRmbr} = "Auf diesem Computer merken";
$lng->{lgiLoginB}    = "Anmelden";
$lng->{lgiFpwTtl}    = "Passwort vergessen";
$lng->{lgiFpwT}      = "Falls Sie Ihr Passwort verloren haben, tragen Sie bitte Ihren Benutzernamen ein und klicken Sie auf Zusenden, um eine Email mit einem Anmeldungs-Ticket-Link an Ihre registrierte Emailadresse zugeschickt zu bekommen. Falls Sie den Benutzernamen ebenfalls vergessen haben, können Sie stattdessen die Emailadresse des Kontos angeben. Bitte benutzen Sie diese Funktion nicht mehrfach hintereinander falls die Email nicht sofort ankommt, da nur der Ticket-Link in der zuletzt verschickten Email gültig ist.";
$lng->{lgiFpwB}      = "Zusenden";
$lng->{lgiFpwMlSbj}  = "Passwort vergessen";
$lng->{lgiFpwMlT}    = "Besuchen Sie bitte den folgenden Ticket-Link, um sich ohne Passwort anzumelden. Sie können dann ein neues Passwort eingeben.\n\nAus Sicherheitsgründen ist der Ticket-Link nur einmal und nur für eine begrenzte Zeit gültig. Außerdem gilt nur der zuletzt zugesandte Ticket-Link, falls Sie sich mehrere haben zuschicken lassen.";

# User registration page
$lng->{regTitle}     = "Benutzer";
$lng->{regRegTtl}    = "Konto registrieren";
$lng->{regRegT}      = "Bitte geben Sie die folgenden Daten ein, um ein Benutzerkonto zu registrieren. Falls Sie schon ein Konto besitzen, können Sie sich auf der <a href='user_login.pl'>Anmelden-Seite</a> anmelden oder sich ein verlorenes Passwort noch einmal zuschicken lassen.";
$lng->{regRegName}   = "Benutzername";
$lng->{regRegEmail}  = "Emailadresse (Anmeldungs-Passwort wird an diese Adresse gesendet)";
$lng->{regRegEmailV} = "Emailadresse wiederholen";
$lng->{regRegB}      = "Registrieren";
$lng->{regMailSubj}  = "Registrierung";
$lng->{regMailT}     = "Sie haben ein Forums-Benutzerkonto registriert.";
$lng->{regMailName}  = "Benutzername: ";
$lng->{regMailPwd}   = "Passwort: ";
$lng->{regMailT2}    = "Nachdem Sie sich per Link oder manuell per Benutzername und Passwort im Forum angemeldet haben, ändern Sie bitte unter \"Optionen\" ihr Passwort und passen Sie Profil und andere Optionen nach Bedarf an.";

# User options page
$lng->{uopTitle}     = "Benutzer";
$lng->{uopPasswd}    = "Passwort";
$lng->{uopPasswdTT}  = "Passwort ändern";
$lng->{uopEmail}     = "Email";
$lng->{uopEmailTT}   = "Emailadresse ändern";
$lng->{uopBoards}    = "Bretter";
$lng->{uopBoardsTT}  = "Brettoptionen einstellen";
$lng->{uopTopics}    = "Themen";
$lng->{uopTopicsTT}  = "Themenoptionen einstellen";
$lng->{uopAvatar}    = "Avatar";
$lng->{uopAvatarTT}  = "Avatarbild auswählen";
$lng->{uopIgnore}    = "Ignorieren";
$lng->{uopIgnoreTT}  = "Andere Benutzer ignorieren";
$lng->{uopOpenPgp}   = "OpenPGP";
$lng->{uopOpenPgpTT} = "OpenPGP-Optionen einstellen";
$lng->{uopInfo}      = "Info";
$lng->{uopInfoTT}    = "Benutzerinfo anzeigen";
$lng->{uopProfTtl}   = "Profil";
$lng->{uopProfRName} = "Realname";
$lng->{uopProfBdate} = "Geburtstag (JJJJ-MM-TT oder MM-TT)";
$lng->{uopProfPage}  = "Website";
$lng->{uopProfOccup} = "Tätigkeit";
$lng->{uopProfHobby} = "Hobbies";
$lng->{uopProfLocat} = "Wohnort";
$lng->{uopProfIcq}   = "Instant Messenger IDs";
$lng->{uopProfSig}   = "Signatur";
$lng->{uopProfSigLt} = "(max. 100 Zeichen auf 2 Zeilen)";
$lng->{uopPrefTtl}   = "Allgemeine Optionen";
$lng->{uopPrefHdEml} = "Eigene Emailadresse verstecken";
$lng->{uopPrefPrivc} = "Eigenen Online-Status verstecken";
$lng->{uopPrefSecLg} = "Anmeldung auf SSL-Verbindungen beschränken (für Experten)";
$lng->{uopPrefMnOld} = "Nachrichten manuell als alt markieren";
$lng->{uopPrefNtMsg} = "Benachrichtigungen über Antworten und private Nachrichten auch per Email empfangen";
$lng->{uopPrefNt}    = "Benachrichtigungen über Antworten empfangen";
$lng->{uopDispTtl}   = "Anzeigeoptionen";
$lng->{uopDispLang}  = "Sprache";
$lng->{uopDispTimeZ} = "Zeitzone";
$lng->{uopDispStyle} = "Stil";
$lng->{uopDispFFace} = "Schriftart";
$lng->{uopDispFSize} = "Schriftgröße (in Pixeln, 0 = Standard)";
$lng->{uopDispIndnt} = "Einzug (1-10%, für Baumstruktur)";
$lng->{uopDispTpcPP} = "Themen pro Seite (0 = benutze erlaubtes Maximum)";
$lng->{uopDispPstPP} = "Nachrichten pro Seite (0 = benutze erlaubtes Maximum)";
$lng->{uopDispDescs} = "Brettbeschreibungen anzeigen";
$lng->{uopDispDeco}  = "Dekoration wie Benutzertitel, Ränge, Smileys anzeigen";
$lng->{uopDispAvas}  = "Avatare anzeigen";
$lng->{uopDispImgs}  = "Eingebettete Bilder anzeigen";
$lng->{uopDispSigs}  = "Signaturen anzeigen";
$lng->{uopDispColl}  = "Themenzweige ohne neue/ungel. Nachrichten zusammenklappen";
$lng->{uopSubmitTtl} = "Optionen ändern";
$lng->{uopSubmitB}   = "Ändern";

# User password page
$lng->{pwdTitle}     = "Benutzer";
$lng->{pwdChgTtl}    = "Passwort ändern";
$lng->{pwdChgT}      = "Benutzen Sie bitte niemals dasselbe Passwort für verschiedene Konten.";
$lng->{pwdChgPwd}    = "Passwort";
$lng->{pwdChgPwdV}   = "Passwort wiederholen";
$lng->{pwdChgB}      = "Ändern";

# User email page
$lng->{emlTitle}     = "Benutzer";
$lng->{emlChgTtl}    = "Emailadresse";
$lng->{emlChgT}      = "Eine neue oder geänderte Emailadresse wird erst wirksam, wenn Sie auf die an diese Adresse gesendete Bestätigungsemail reagiert haben.";
$lng->{emlChgAddr}   = "Emailadresse";
$lng->{emlChgAddrV}  = "Emailadresse wiederholen";
$lng->{emlChgB}      = "Ändern";
$lng->{emlChgMlSubj} = "Emailadressen-Änderung";
$lng->{emlChgMlT}    = "Sie haben eine Änderung Ihrer Emailadresse beantragt. Um die Gültigkeit der neuen Adresse zu verifizieren, wird die Adresse erst geändert, wenn Sie den folgenden Ticket-Link besuchen:";

# User board options page
$lng->{ubdTitle}     = "Benutzer";
$lng->{ubdBrdStTtl}  = "Brettoptionen";
$lng->{ubdBrdStSubs} = "Abonnieren";
$lng->{ubdBrdStHide} = "Verstecken";
$lng->{ubdSubmitTtl} = "Brettoptionen ändern";
$lng->{ubdChgB}      = "Ändern";

# User topic options page
$lng->{utpTitle}     = "Benutzer";
$lng->{utpTpcStTtl}  = "Themenoptionen";
$lng->{utpTpcStSubs} = "Abonnieren";
$lng->{utpEmpty}     = "Keine Themen mit aktivierten Optionen gefunden.";
$lng->{utpSubmitTtl} = "Themenoptionen ändern";
$lng->{utpChgB}      = "Ändern";

# Avatar page
$lng->{avaTitle}     = "Benutzer";
$lng->{avaUplTtl}    = "Eigener Avatar";
$lng->{avaUplFile}   = "JPG/PNG/GIF-Bild, max. Größe [[bytes]] Bytes, genaue Dimensionen [[width]]x[[height]] Pixel, keine Animation.";
$lng->{avaUplResize} = "Nicht konforme Bilder werden automatisch umformatiert, was nicht unbedingt das beste Ergebnis liefert.";
$lng->{avaUplUplB}   = "Hochladen";
$lng->{avaUplDelB}   = "Löschen";
$lng->{avaGalTtl}    = "Avatar-Galerie";
$lng->{avaGalSelB}   = "Auswählen";
$lng->{avaGalDelB}   = "Entfernen";

# User ignore page
$lng->{uigTitle}     = "Benutzer";
$lng->{uigAddT}      = "Wenn Sie einen anderen Benutzer ignorieren, werden dessen private Nachrichten an Sie verworfen, und öffentliche Nachrichten des Benutzers werden Ihnen nicht angezeigt (können aber gezielt aufgedeckt werden).";
$lng->{uigAddTtl}    = "Benutzer ignorieren";
$lng->{uigAddUser}   = "Benutzername";
$lng->{uigAddB}      = "Ignorieren";
$lng->{uigRemTtl}    = "Benutzer nicht mehr ignorieren";
$lng->{uigRemUser}   = "Benutzername";
$lng->{uigRemB}      = "Entfernen";

# Group info page
$lng->{griTitle}     = "Gruppe";
$lng->{griMbrTtl}    = "Mitglieder";
$lng->{griBrdAdmTtl} = "Brettmoderator-Befugnisse";
$lng->{griBrdMbrTtl} = "Brettmitglieds-Befugnisse";

# Board membership page
$lng->{mbrTitle}     = "Brett";
$lng->{mbrAddTtl}    = "Mitglied hinzufügen";
$lng->{mbrAddUser}   = "Benutzername";
$lng->{mbrAddB}      = "Hinzufügen";
$lng->{mbrRemTtl}    = "Mitglied entfernen";
$lng->{mbrRemUser}   = "Benutzername";
$lng->{mbrRemB}      = "Entfernen";

# Board groups page
$lng->{bgrTitle}     = "Brett";
$lng->{bgrPermTtl}   = "Befugnisse";
$lng->{bgrModerator} = "Moderator";
$lng->{bgrMember}    = "Mitglied";
$lng->{bgrChangeTtl} = "Befugnisse ändern";
$lng->{bgrChangeB}   = "Ändern";

# Topic tag page
$lng->{ttgTitle}     = "Thema";
$lng->{ttgTagTtl}    = "Thema-Tag";
$lng->{ttgTagB}      = "Taggen";

# Topic move page
$lng->{mvtTitle}     = "Thema";
$lng->{mvtMovTtl}    = "Thema verschieben";
$lng->{mvtMovDest}   = "Zielbrett";
$lng->{mvtMovB}      = "Verschieben";

# Topic merge page
$lng->{mgtTitle}     = "Thema";
$lng->{mgtMrgTtl}    = "Themen zusammenlegen";
$lng->{mgtMrgDest}   = "Zielthema";
$lng->{mgtMrgDest2}  = "Alternative manuelle ID-Eingabe (für ältere Themen und Themen in anderen Brettern)";
$lng->{mgtMrgB}      = "Zusammenlegen";

# Branch page
$lng->{brnTitle}     = "Themenzweig";
$lng->{brnPromoTtl}  = "Zu Thema umwandeln";
$lng->{brnPromoSbj}  = "Betreff";
$lng->{brnPromoBrd}  = "Brett";
$lng->{brnPromoLink} = "Querverweis-Nachrichten einfügen";
$lng->{brnPromoB}    = "Umwandeln";
$lng->{brnProLnkBdy} = "Themenzweig verschoben";
$lng->{brnMoveTtl}   = "Verschieben";
$lng->{brnMovePrnt}  = "ID der übergeordneten Nachricht (kann in anderem Thema sein, 0 = mache zu erster Nachricht)";
$lng->{brnMoveB}     = "Verschieben";
$lng->{brnDeleteTtl} = "Löschen";
$lng->{brnDeleteB}   = "Löschen";

# Search page
$lng->{seaTitle}     = "Suche";
$lng->{seaTtl}       = "Kriterien";
$lng->{seaAdvOpt}    = "Mehr";
$lng->{seaBoard}     = "Brett";
$lng->{seaBoardAll}  = "Alle Bretter";
$lng->{seaWords}     = "Wörter";
$lng->{seaWordsChng} = "Einige Wörter und/oder Zeichen wurden geändert oder entfernt, da der aus Geschwindigkeitsgründen benutzte Volltextindex die Suche nach genau dem eingetippten Ausdruck nicht unterstützt. Dies betrifft Wörter mit weniger als drei Buchstaben, häufig vorkommende Wörter sowie Sonderzeichen außerhalb von Anführungszeichen.";
$lng->{seaUser}      = "Schreiber";
$lng->{seaMinAge}    = "Min. Alter";
$lng->{seaMaxAge}    = "Max. Alter";
$lng->{seaField}     = "Feld";
$lng->{seaFieldBody} = "Text";
$lng->{seaFieldSubj} = "Betreff";
$lng->{seaSort}      = "Sort.";
$lng->{seaSortTime}  = "Datum";
$lng->{seaSortUser}  = "Schreiber";
$lng->{seaSortRelev} = "Relevanz";
$lng->{seaOrder}     = "Reihenf.";
$lng->{seaOrderAsc}  = "Aufst.";
$lng->{seaOrderDesc} = "Abst.";
$lng->{seaShowBody}  = "Text anzeigen";
$lng->{seaB}         = "Suchen";
$lng->{serTopic}     = "Thema";
$lng->{serRelev}     = "Relevanz";
$lng->{serPoster}    = "Schreiber";
$lng->{serPosted}    = "Datum";
$lng->{serNotFound}  = "Keine Treffer gefunden.";

# Help page
$lng->{hlpTitle}     = "Hilfe";
$lng->{hlpTxtTtl}    = "Begriffe und Funktionen";
$lng->{hlpFaqTtl}    = "Häufig gestellte Fragen";

# Message list page
$lng->{mslTitle}     = "Private Nachrichten";
$lng->{mslSend}      = "Nachricht senden";
$lng->{mslSendTT}    = "Private Nachricht an beliebigen Empfänger senden";
$lng->{mslDelAll}    = "Alle gelesenen löschen";
$lng->{mslDelAllTT}  = "Alle gelesenen und gesendeten Nachrichten löschen";
$lng->{mslInbox}     = "Eingang";
$lng->{mslOutbox}    = "Gesendet";
$lng->{mslFrom}      = "Absender";
$lng->{mslTo}        = "Empfänger";
$lng->{mslDate}      = "Datum";
$lng->{mslCommands}  = "Aktionen";
$lng->{mslDelete}    = "Löschen";
$lng->{mslNotFound}  = "Keine privaten Nachrichten vorhanden.";
$lng->{mslExpire}    = "Private Nachrichten werden nach [[days]] Tagen gelöscht.";

# Add message page
$lng->{msaTitle}     = "Private Nachricht";
$lng->{msaSendTtl}   = "Private Nachricht senden";
$lng->{msaSendRecv}  = "Empfänger";
$lng->{msaSendSbj}   = "Betreff";
$lng->{msaSendTxt}   = "Text";
$lng->{msaSendB}     = "Absenden";
$lng->{msaSendPrvB}  = "Vorschau";
$lng->{msaPrvTtl}    = "Vorschau";
$lng->{msaRefTtl}    = "Antwort auf Nachricht von";
$lng->{msaEmailSbj}  = "Private Nachricht";
$lng->{msaEmailTSbj} = "Betreff: ";
$lng->{msaEmailUsr}  = "Absender: ";
$lng->{msaEmailUrl}  = "Link: ";
$lng->{msaEmailT2}   = "Dies ist eine automatische Benachrichtigung der Forumssoftware.\nBitte nicht auf diese Email antworten, sondern im Forum.";

# Message page
$lng->{mssTitle}     = "Private Nachricht";
$lng->{mssDelete}    = "Löschen";
$lng->{mssDeleteTT}  = "Nachricht löschen";
$lng->{mssReply}     = "Antworten";
$lng->{mssReplyTT}   = "Auf Nachricht antworten";
$lng->{mssQuote}     = "Zitieren";
$lng->{mssQuoteTT}   = "Auf Nachricht antworten mit Zitat";
$lng->{mssFrom}      = "Von";
$lng->{mssTo}        = "An";
$lng->{mssDate}      = "Datum";
$lng->{mssSubject}   = "Betreff";

# Blog page
$lng->{blgTitle}     = "Blog";
$lng->{blgSubject}   = "Thema";
$lng->{blgDate}      = "Datum";
$lng->{blgComment}   = "Kommentare";
$lng->{blgCommentTT} = "Kommentare anzeigen und schreiben";
$lng->{blgExpire}    = "Blog topics expire after [[days]] days.";

# Chat page
$lng->{chtTitle}     = "Chat";
$lng->{chtRefresh}   = "Aktualisieren";
$lng->{chtRefreshTT} = "Seite aktualisieren";
$lng->{chtDelAll}    = "Alle Löschen";
$lng->{chtDelAllTT}  = "Alle Nachrichten löschen";
$lng->{chtAddTtl}    = "Nachricht schreiben";
$lng->{chtAddB}      = "Schreiben";
$lng->{chtMsgsTtl}   = "Nachrichten";

# Attachment list page
$lng->{aliTitle}     = "Dateianhangsliste";
$lng->{aliLfmTtl}    = "Listenformat";
$lng->{aliLfmSearch} = "Dateiname";
$lng->{aliLfmBoard}  = "Brett";
$lng->{aliLfmSort}   = "Sort.";
$lng->{aliLfmSrtFNm} = "Dateiname";
$lng->{aliLfmSrtUNm} = "Benutzername";
$lng->{aliLfmSrtPTm} = "Datum";
$lng->{aliLfmOrder}  = "Reihenf.";
$lng->{aliLfmOrdAsc} = "Aufst.";
$lng->{aliLfmOrdDsc} = "Abst.";
$lng->{aliLfmGall}   = "Galerie";
$lng->{aliLfmListB}  = "Auflisten";
$lng->{aliLstFile}   = "Dateiname";
$lng->{aliLstSize}   = "Größe";
$lng->{aliLstPost}   = "Nachricht";
$lng->{aliLstUser}   = "Benutzer";

# Email subscriptions
$lng->{subSubjBrd}   = "Abo von Brett";
$lng->{subSubjTpc}   = "Abo von Thema";
$lng->{subNoReply}   = "Dies ist eine automatische Abonnements-Email der Forumssoftware.\nBitte antworten Sie nicht auf diese Email, sondern im Forum.";
$lng->{subTopic}     = "Thema: ";
$lng->{subBy}        = "Von: ";
$lng->{subOn}        = "Datum: ";

# Feeds
$lng->{fedTitle}     = "Feeds";
$lng->{fedAllBoards} = "Alle öffentlichen Bretter";
$lng->{fedAllBlogs}  = "Alle Blogs";

# Bounce detection
$lng->{bncWarning}   = "Warnung: Ihr Emailkonto verweigert die Annahme von Emails dieses Forums oder existiert nicht mehr. Bitte korrigieren Sie die Situation, da das Forum sonst evtl. die Zusendung von Emails an Sie einstellen muss.";

# Confirmation
$lng->{cnfTitle}     = "Bestätigung";
$lng->{cnfDelAllMsg} = "Wirklich alle gelesenen Nachrichten löschen?";
$lng->{cnfDelAllCht} = "Wirklich alle Chat-Nachrichten löschen?";
$lng->{cnfQuestion}  = "Wirklich";
$lng->{cnfQuestion2} = " löschen?";
$lng->{cnfTypeUser}  = "Benutzer";
$lng->{cnfTypeGroup} = "Gruppe";
$lng->{cnfTypeCateg} = "Kategorie";
$lng->{cnfTypeBoard} = "Brett";
$lng->{cnfTypeTopic} = "Thema";
$lng->{cnfTypePoll}  = "Umfrage";
$lng->{cnfTypePost}  = "Nachricht";
$lng->{cnfTypeMsg}   = "private Nachricht";
$lng->{cnfDeleteB}   = "Löschen";

# Notification messages
$lng->{notNotify}    = "Benutzer benachrichtigen (optional Grund angeben)";
$lng->{notReason}    = "Grund:";
$lng->{notMsgAdd}    = "[[usrNam]] hat eine private <a href='[[msgUrl]]'>Nachricht</a> gesendet.";
$lng->{notPstAdd}    = "[[usrNam]] hat auf eine <a href='[[pstUrl]]'>Nachricht</a> geantwortet.";
$lng->{notPstEdt}    = "Ein Moderator hat eine <a href='[[pstUrl]]'>Nachricht</a> geändert.";
$lng->{notPstDel}    = "Ein Moderator hat eine <a href='[[tpcUrl]]'>Nachricht</a> gelöscht.";
$lng->{notTpcMov}    = "Ein Moderator hat ein <a href='[[tpcUrl]]'>Thema</a> verschoben.";
$lng->{notTpcDel}    = "Ein Moderator hat ein Thema namens \"[[tpcSbj]]\" gelöscht.";
$lng->{notTpcMrg}    = "Ein Moderator hat ein Thema mit einem anderen <a href='[[tpcUrl]]'>Thema</a> zusammengelegt.";
$lng->{notEmlReg}    = "Willkommen, [[usrNam]]! Geben Sie bitte Ihre <a href='[[emlUrl]]'>Emailadresse</a> ein, um die emailbasierten Funktionen zu aktivieren.";

# Top bar messages
$lng->{msgReplyPost} = "Nachricht eingetragen";
$lng->{msgNewPost}   = "Thema eingetragen";
$lng->{msgPstChange} = "Nachricht geändert";
$lng->{msgPstDel}    = "Nachricht gelöscht";
$lng->{msgPstTpcDel} = "Nachricht/Thema gelöscht";
$lng->{msgPstApprv}  = "Nachricht bestätigt";
$lng->{msgPstAttach} = "Dateianhang angefügt";
$lng->{msgPstDetach} = "Dateianhang gelöscht";
$lng->{msgPstAttTgl} = "Einbettung umgeschaltet";
$lng->{msgOptChange} = "Optionen geändert";
$lng->{msgPwdChange} = "Passwort geändert";
$lng->{msgAccntReg}  = "Konto registriert";
$lng->{msgMemberAdd} = "Mitglied hinzugefügt";
$lng->{msgMemberRem} = "Mitglied entfernt";
$lng->{msgTpcDelete} = "Thema gelöscht";
$lng->{msgTpcStik}   = "Thema fixiert";
$lng->{msgTpcUnstik} = "Thema defixiert";
$lng->{msgTpcLock}   = "Thema gesperrt";
$lng->{msgTpcUnlock} = "Thema entsperrt";
$lng->{msgTpcMove}   = "Thema verschoben";
$lng->{msgTpcMerge}  = "Themen zusammengelegt";
$lng->{msgBrnPromo}  = "Zweig befördert";
$lng->{msgBrnMove}   = "Zweig verschoben";
$lng->{msgBrnDelete} = "Zweig gelöscht";
$lng->{msgPstAddTdo} = "Nachricht auf Merkliste gesetzt";
$lng->{msgPstRemTdo} = "Nachricht von Merkliste entfernt";
$lng->{msgPstAddRep} = "Beschwerde eingelegt";
$lng->{msgPstRemRep} = "Beschwerde gelöscht";
$lng->{msgMarkOld}   = "Nachrichten als alt markiert";
$lng->{msgMarkRead}  = "Nachrichten als gelesen markiert";
$lng->{msgPollAdd}   = "Umfrage hinzugefügt";
$lng->{msgPollDel}   = "Umfrage gelöscht";
$lng->{msgPollLock}  = "Umfrage beendet";
$lng->{msgPollVote}  = "Abgestimmt";
$lng->{msgMsgAdd}    = "Private Nachricht gesendet";
$lng->{msgMsgDel}    = "Private Nachricht(en) gelöscht";
$lng->{msgChatAdd}   = "Chat-Nachricht eingetragen";
$lng->{msgChatDel}   = "Chat-Nachricht(en) gelöscht";
$lng->{msgIgnoreAdd} = "Benutzer wird ignoriert";
$lng->{msgIgnoreRem} = "Benutzer wird nicht mehr ignoriert";
$lng->{msgCfgChange} = "Forumskonfiguration geändert";
$lng->{msgEolTpc}    = "Keine weiteren Themen in dieser Richtung";
$lng->{msgTksFgtPwd} = "Email zugesendet";
$lng->{msgTkaFgtPwd} = "Eingeloggt, Sie können jetzt Ihr Passwort ändern";
$lng->{msgTkaEmlChg} = "Emailadresse geändert";
$lng->{msgCronExec}  = "Cronjob ausgeführt";
$lng->{msgTpcTag}    = "Thema getaggt";
$lng->{msgTpcSub}    = "Thema abonniert";
$lng->{msgTpcUnsub}  = "Thema abbestellt";
$lng->{msgTpcUnsAll} = "Alle Themen abbestellt";
$lng->{msgNotesDel}  = "Benachrichtigungen entfernt";

# Error messages
$lng->{errDefault}   = "[Fehlertext fehlt]";
$lng->{errGeneric}   = "Fehler";
$lng->{errText}      = "Falls dies ein echter Fehler ist, können Sie den Administrator informieren, bitte mit genauer Fehlerbeschreibung und Fehlerzeitpunkt.";
$lng->{errUser}      = "Benutzerfehler";
$lng->{errForm}      = "Formularfehler";
$lng->{errDb}        = "Datenbankfehler";
$lng->{errEntry}     = "Datenbankeintragsfehler";
$lng->{errParam}     = "CGI Parameterfehler";
$lng->{errConfig}    = "Konfigurationsfehler";
$lng->{errMail}      = "Emailfehler";
$lng->{errNote}      = "Hinweis";
$lng->{errParamMiss} = "Nötiger Parameter fehlt.";
$lng->{errCatIdMiss} = "Kategorie-ID fehlt.";
$lng->{errBrdIdMiss} = "Brett-ID fehlt.";
$lng->{errTpcIdMiss} = "Thema-ID fehlt.";
$lng->{errUsrIdMiss} = "Benutzer-ID fehlt.";
$lng->{errGrpIdMiss} = "Gruppen-ID fehlt.";
$lng->{errPstIdMiss} = "Nachricht-ID fehlt.";
$lng->{errPrtIdMiss} = "ID der beantworteten Nachricht fehlt.";
$lng->{errMsgIdMiss} = "Message ID is missing.";
$lng->{errTPIdMiss}  = "Thema oder Nachricht-ID fehlt.";
$lng->{errCatNotFnd} = "Kategorie nicht vorhanden.";
$lng->{errBrdNotFnd} = "Brett nicht vorhanden.";
$lng->{errTpcNotFnd} = "Thema nicht vorhanden.";
$lng->{errPstNotFnd} = "Nachricht nicht vorhanden.";
$lng->{errPrtNotFnd} = "Beantwortete Nachricht nicht vorhanden.";
$lng->{errMsgNotFnd} = "Private Nachricht nicht vorhanden.";
$lng->{errUsrNotFnd} = "Benutzer nicht vorhanden.";
$lng->{errGrpNotFnd} = "Gruppe nicht vorhanden.";
$lng->{errTktNotFnd} = "Ticket nicht vorhanden. Tickets verfallen nach zwei Tagen, und nur das zuletzt zugesandte Ticket eines Typs ist gültig.";
$lng->{errUsrDel}    = "Benutzerkonto existiert nicht mehr.";
$lng->{errUsrFake}   = "Kein echtes Benutzerkonto.";
$lng->{errSubEmpty}  = "Betreff ist leer.";
$lng->{errBdyEmpty}  = "Nachrichtentext ist leer.";
$lng->{errNamEmpty}  = "Benutzername ist leer.";
$lng->{errPwdEmpty}  = "Passwort ist leer.";
$lng->{errEmlEmpty}  = "Emailadresse ist leer.";
$lng->{errEmlInval}  = "Emailadresse ist ungültig.";
$lng->{errWordEmpty} = "Suchbegriff-Feld ist leer.";
$lng->{errNamSize}   = "Benutzername ist zu kurz oder zu lang.";
$lng->{errPwdSize}   = "Passwort ist zu kurz oder zu lang.";
$lng->{errEmlSize}   = "Emailadresse ist zu kurz oder zu lang.";
$lng->{errNamChar}   = "Benutzername enthält ungültige Zeichen.";
$lng->{errPwdChar}   = "Passwort enthält ungültige Zeichen.";
$lng->{errPwdWrong}  = "Passwort ist falsch.";
$lng->{errReg}       = "Diese Funktion kann nur von einem registrierten und eingeloggten Benutzer genutzt werden.";
$lng->{errBlocked}   = "Zugriff verweigert";
$lng->{errBannedT}   = "Benutzerkonto ist gesperrt. Grund:";
$lng->{errBannedT2}  = "Dauer: ";
$lng->{errBannedT3}  = "Tage.";
$lng->{errBlockedT}  = "Ihre IP-Adresse ist auf der schwarzen Liste des Forums.";
$lng->{errBlockEmlT} = "Ihre Email-Domain ist auf der schwarzen Liste des Forums.";
$lng->{errAuthz}     = "Nicht autorisiert";
$lng->{errAdmin}     = "Sie besitzen nicht die nötigen Zugriffsrechte.";
$lng->{errCheat}     = "Netter Versuch.";
$lng->{errSubLen}    = "Maximale Betrefflänge überschritten.";
$lng->{errBdyLen}    = "Maximale Nachrichtenlänge überschritten.";
$lng->{errReadOnly}  = "Nur Administratoren, Moderatoren und Mitglieder können in dieses Brett schreiben.";
$lng->{errModOwnPst} = "Sie können nicht Ihre eigenen Nachrichten moderieren.";
$lng->{errTpcLocked} = "Thema ist gesperrt, Sie können nicht mehr schreiben, editieren oder abstimmen.";
$lng->{errSubNoText} = "Betreff enthält keinen echten Text.";
$lng->{errNamGone}   = "Benutzername ist schon vergeben.";
$lng->{errEmlGone}   = "Emailadresse ist schon registriert. Es ist nur ein Konto pro Adresse erlaubt.";
$lng->{errPwdDiffer} = "Passwörter sind nicht identisch.";
$lng->{errEmlDiffer} = "Emailadressen sind nicht identisch.";
$lng->{errDupe}      = "Nachricht ist schon eingetragen.";
$lng->{errAttName}   = "Keine Datei oder kein Dateiname angegeben.";
$lng->{errAttSize}   = "Upload fehlt, wurde abgeschnitten oder übertrifft maximale Größe.";
$lng->{errAttDisab}  = "Dateianhänge sind deaktiviert.";
$lng->{errPromoTpc}  = "Diese Nachricht ist die Basisnachricht des ganzen Themas.";
$lng->{errRollback}  = "Transaktion wurde rückgängig gemacht.";
$lng->{errPstEdtTme} = "Nachrichten können nur einen begrenzte Zeitraum nach dem Abschicken editiert werden. Dieser Zeitraum ist bereits abgelaufen.";
$lng->{errNoEmail}   = "Das Benutzerkonto hat keine Emailadresse.";
$lng->{errDontEmail} = "Das Senden von Emails für Ihr Konto wurde von einem Administrator deaktiviert. Typische Gründe dafür sind ungültige Emailadressen, überfüllte Postfächer oder aktivierte Autoresponder.";
$lng->{errEditAppr}  = "Das Editieren von Nachrichten in moderierten Brettern ist nicht mehr erlaubt, sobald sie von einem Administrator oder Moderator bestätigt wurden.";
$lng->{errAdmUsrReg} = "Benutzerkonten können in diesem Forum nur von Administratoren registriert werden.";
$lng->{errTdoDupe}   = "Diese Nachricht ist bereits auf der Merkliste.";
$lng->{errRepOwn}    = "Eine Beschwerde über eine eigene Nachricht macht wenig Sinn.";
$lng->{errRepDupe}   = "Es gibt bereits eine Beschwerde über diese Nachricht.";
$lng->{errRepReason} = "Begründung ist leer.";
$lng->{errSrcAuth}   = "Zugriffsauthentifizierung ist fehlgeschlagen. Entweder hat jemand versucht, Ihnen eine Aktion unterzuschieben (speziell falls Sie gerade von einer fremden Seite gekommen sind), oder die Authentifizierungswerte wurde nur zufällig gerade erneuert. In letzterem Fall bitte einfach die versuchte Aktion nochmal wiederholen.";
$lng->{errPolExist}  = "Thema hat bereits eine Umfrage.";
$lng->{errPolOneOpt} = "Eine Umfrage benötigt mindestens zwei Optionen.";
$lng->{errPolNoDel}  = "Nur Umfragen ohne abgegebene Stimmen können gelöscht werden.";
$lng->{errPolNoOpt}  = "Keine Option ausgewählt.";
$lng->{errPolNotFnd} = "Umfrage nicht vorhanden.";
$lng->{errPolLocked} = "Umfrage ist beendet.";
$lng->{errPolOpNFnd} = "Umfrageoption nicht vorhanden.";
$lng->{errPolVotedP} = "Sie können nur einmal für diese Umfrage abstimmen.";
$lng->{errFeatDisbl} = "Diese Funktion ist deaktiviert.";
$lng->{errAvaSizeEx} = "Maximale Dateigröße überschritten.";
$lng->{errAvaDimens} = "Bild muss angegebene Breite und Höhe haben.";
$lng->{errAvaFmtUns} = "Dateiformat ungültig oder nicht unterstützt.";
$lng->{errAvaNoAnim} = "Animierte Bilder sind nicht erlaubt.";
$lng->{errRepostTim} = "Spamschutz aktiviert. Bitte warten Sie [[seconds]] Sekunden, bis Sie wieder eine Nachricht abschicken können.";
$lng->{errCrnEmuBsy} = "Das Forum ist zurzeit mit Wartungsarbeiten beschäftigt. Bitte kommen Sie später wieder.";
$lng->{errForumLock} = "Das Forum ist zurzeit geschlossen. Bitte kommen Sie später wieder.";
$lng->{errMinRegTim} = "Sie müssen für mindestens [[hours]] Stunde(n) registriert sein, um diese Funktion benutzen zu können.";
$lng->{errSsnTmeout} = "Anmeldung ist abgelaufen, ungültig oder gehört jemandem anders. Sie können dieses Problem vermeiden, indem Sie dieser Website das Setzen von Cookies erlauben.";
$lng->{errDbHidden}  = "Ein Datenbankfehler ist aufgetreten und wurde geloggt.";
$lng->{errCptTmeOut} = "Anti-Spam-Bild ist abgelaufen. Sie haben [[seconds]] Sekunden Zeit, um das Formular abzuschicken.";
$lng->{errCptWrong}  = "Buchstaben vom Anti-Spam-Bild sind nicht korrekt. Bitte versuchen Sie es nochmal.";
$lng->{errCptFail}   = "Sie haben den Spambot-Test nicht bestanden.";


#------------------------------------------------------------------------------
# Help

$lng->{help} = "
<h3>Forum</h3>

<p>Als Forum wird die komplette Installation bezeichnet, die gewöhnlich
mehrere Bretter enthält. Man sollte das Forum immer durch den Link betreten,
der auf forum.pl (nicht forum_show.pl) endet, damit das Forum weiss, wann man
eine Session beginnt, und berechnen kann, welche Nachrichten alt und welche
neu sind.</p>

<h3>Benutzer</h3>

<p>Ein Benutzer ist jemand, der im Forum ein Konto registriert hat. Zum Lesen
ist zwar im allgemeinen kein Konto notwendig, allerdings bekommen
unregistrierte Leser keine Neu/Gelesen-Statistiken. Benutzer können Mitglied
in bestimmten Brettern werden, wodurch sie sonst unsichtbare private Bretter
sehen können und in schreibgeschützten Brettern schreiben können.</p>

<h3>Brett</h3>

<p>Ein Brett enthält Themen zu einem dem Brettnamen entsprechenden 
Themenbereich. Bretter können so eingestellt werden, so dass sie nur für 
registrierte Benutzer oder nur für Administratoren, Moderatoren und 
Brettmitglieder sichtbar sind. Bretter können anonym sein, so dass die 
Identität des Schreibers nicht in der Nachricht gespeichert wird (völlige 
Anonymität vor Administratoren kann dies aber nicht garantieren), und können 
optional das Schreiben von Nachrichten durch unregistrierte Besucher erlauben. 
Bretter können schreibgeschützt sein, so dass nur Administratoren, Moderatoren 
und Mitglieder in ihnen schreiben können, sowie so eingestellt werden, dass nur 
Administratoren, Moderatoren und Mitglieder neue Themen starten können, auf 
die dann aber jeder Benutzer antworten kann. Eine weitere Option für Bretter 
nennt sich Bestätigungsmoderation, bei deren Aktivierung neue Nachrichten von 
Administratoren oder Moderatoren bestätigt werden müssen, um für normale 
Benutzer sichtbar zu sein. Benutzer können Bretter abonnieren, wobei sie dann 
regelmäßig die neuen Nachrichten in diesem Brett gesammelt in einer Email 
zugesandt bekommen (Haufigkeit hängt von der Forumskonfiguration ab).</p>

<h3>Thema</h3>

<p>Ein Thema enthält alle Nachrichten zu einer bestimmten Angelegenheit, die im 
Betreff angegeben sein sollte. Die Nachrichten können entweder in einer 
Baumstruktur angeordnet sein, der man entnehmen kann, welche Nachricht sich auf 
welchen Vorgänger bezieht, oder sie können alle sequentiell hintereinander 
stehen. Bretter haben Zeiten, die angeben, wie lange es dauert, bevor ihre 
Themen gelöscht und/oder gesperrt werden. Themen können von Administratoren und 
Moderatoren auch manuell gesperrt werden, so dass man keine neue Nachrichten 
hineinschreiben kann. Benutzer können Thema abonnieren, wobei sie dann 
regelmäßig die neuen Nachrichten in diesem Thema gesammelt in einer Email 
zugesandt bekommen (Haufigkeit hängt von der Forumskonfiguration ab).</p>

<h3>Öffentliche Nachricht</h3>

<p>Eine Nachricht ist ein öffentlicher Kommentar eines Benutzers zu einem 
Thema. Es kann entweder eine Nachricht mit Betreff sein, die ein neues Thema 
beginnt, oder eine Antwort zu einem existierenden Thema. Nachrichten können 
nachträglich editiert und gelöscht werden, was allerdings zeitlich begrenzt 
sein kann. Nachrichten können einer persönlichen Merkliste hinzugefügt und im 
Falle von Regelverstößen den Administratoren und Moderatoren gemeldet 
werden.</p>

<h3>Private Nachricht</h3>

<p>Zusätzlich zu den öffentlichen Nachrichten können in einem Forum auch die
privaten Nachrichten aktiviert sein, die sich registrierte Benutzer
gegenseitig zuschicken können, ohne die Emailadresse des anderen zu
kennen.</p>

<h3>Administrator</h3>

<p>Ein Administrator kann alles im Forum kontrollieren und editieren. Ein
Forum kann mehrere Administratoren haben.</p>

<h3>Moderator</h3>

<p>Die Macht eines Moderators ist auf bestimmte Bretter beschränkt. Ein 
Moderator kann Nachrichten aller Benutzer des Brettes editieren, löschen und 
bestätigen, Themen löschen und sperren, Brettmitglieder hinzufügen und 
entfernen sowie die Beschwerdeliste einsehen. Ein Brett kann mehrere 
Moderatoren haben.</p>

<h3>Umfragen</h3>

<p>Der Besitzer eines Themas kann diesem eine Umfrage hinzufügen. Jede Umfrage
kann bis zu 20 Optionen enthalten. Registrierte Benutzer können pro Umfrage
eine Stimme für eine einzelne Option abgeben. Umfragen können nicht editiert
werden, und können nur so lange wieder gelöscht werden, wie noch keine Stimme
abgegeben wurde.</p>

<h3>Icons</h3>

<table>
<tr><td>
<img src='[[dataPath]]/post_nu.png' alt='N/U'/>
<img src='[[dataPath]]/topic_nu.png' alt='N/U'/>
<img src='[[dataPath]]/board_nu.png' alt='N/U'/>
</td><td>
Gelbe Icons zeigen neue Nachrichten bzw. Themen oder Bretter mit neuen
Nachrichten an. In diesem Forum bedeutet neu, dass eine Nachricht seit dem
letzten Besuch hinzugekommen ist. Auch wenn eine Nachricht gerade gelesen
wurde, gilt sie immer noch als neu, und wird erst beim nächsten Besuch als alt
gewertet.
</td></tr>
<tr><td>
<img src='[[dataPath]]/post_or.png' alt='O/R'/>
<img src='[[dataPath]]/topic_or.png' alt='O/R'/>
<img src='[[dataPath]]/board_or.png' alt='O/R'/>
</td><td>
Abgehakte Icons bedeuten, dass eine Nachricht bzw. alle Nachrichten in einem
Thema oder Brett gelesen wurden. Als gelesen werden alle Nachrichten gewertet,
die einmal anzeigt wurden oder älter als eine bestimmte Anzahl von Tagen
sind. Da neu/alt und ungelesen/gelesen in diesem Forum unabhängige Konzepte
sind, können Nachrichten auch gleichzeitig neu und gelesen sowie alt und
ungelesen sein.
</td></tr>
<tr><td>
<img src='[[dataPath]]/post_i.png' alt='I'/>
</td><td>
Die jeweilige Nachricht bzw. das Thema sind für andere Benutzer 
unsichtbar sind, da sie noch auf Bestätigung durch einen Administrator 
oder Moderator warten.
</td></tr>
<tr><td>
<img src='[[dataPath]]/topic_l.png' alt='L'/>
</td><td>
Das Schloss-Icon bedeutet, dass das entsprechende Thema gesperrt ist, und außer
Administratoren und Moderatoren niemand mehr neue Antworten schreiben kann.
</td></tr>
</table>

<h3>Formatierungs-Tags</h3>

<p>Aus Sicherheitsgründen unterstützt mwForum nur seine eigenen 
Formatierungs-Tags, kein HTML. Verfügbare Tags:</p>

<table>
<tr><td>[b]Text[/b]</td>
<td>zeigt Text <b>fett</b> an</td></tr>
<tr><td>[i]Text[/i]</td>
<td>zeigt Text <i>kursiv</i> an</td></tr>
<tr><td>[tt]Text[/tt]</td>
<td>zeigt Text <tt>nichtproportional</tt> an</td></tr>
<tr><td>[img]Adresse[/img]</td>
<td>bettet ein Bild ein (wenn die Funktion aktiviert ist)</td></tr>
<tr><td>[url]Adresse[/url]</td>
<td>macht die Adresse zu einem Link</td></tr>
<tr><td>[url=Adresse]Text[/url]</td>
<td>macht Text zu einem Link für die Adresse</td></tr>
</table>

<h3>Smileys</h3>

<p>Die folgenden Emoticons werden als Bilder dargestellt (wenn die
entsprechende Funktion aktiviert ist): :-) :-D ;-) :-( :-o :-P</p>

";

#------------------------------------------------------------------------------
# FAQ

$lng->{faq} = "

<h3>Ich habe mein Passwort verloren, können Sie mir das zuschicken?</h3>

<p>Nein, das originale Passwort wird aus Sicherheitsgründen nirgendwo 
gespeichert. Auf der Anmeldeseite können Sie jedoch eine Email mit einer 
speziellen Anmelde-URL anfordern, die eine begrenzte Zeit gültig ist, und mit 
der Sie wieder einloggen können. Danach können Sie dann das Passwort 
ändern.</p>

<h3>Warum diese umständliche Registrierung per Passwortzusendung?</h3>

<p>Dieses Forum hat diverse Funktionen, die dem Benutzer Emails zusenden 
können, z.B. Antwortbenachrichtigungen und Brettabonnements. Das Forum 
verlangt die Angabe einer gültigen Emailadresse und sendet das nötige Passwort 
nur an diese Adresse, um damit die Gültigkeit der Adresse sicherzustellen. 
Damit wird verhindert, dass Benutzer falsche oder inkorrekte Adressen angeben, 
und dann aber trotzdem die Emailfunktionen benutzen, was zu massenhaft 
fehlgeleiteten Emails und Fehlermeldungen für die Administratoren führen 
würde. Außerdem fungiert das Registrierungsverfahren auch als 
\"doppelte Opt-In\"-Lösung, die verhindert, dass das Forum zum Email-Spammen
anderer Leute mißbraucht werden kann.</p>

<h3>Wann muss man sich abmelden?</h3>

<p>Man braucht sich nur abzumelden, wenn der benutzte Computer auch von nicht
vertrauenswürdigen Personen benutzt wird. Wie oben geschrieben werden
Benutzer-ID und Passwort per Cookie auf dem Computer gespeichert. Diese werden
beim Abmelden entfernt, so dass sie nicht von einer anderen Person missbraucht
werden können.</p>

<h3>Wie kann man Bilder und andere Dateien an Nachrichten anhängen?</h3>

<p>Wenn Dateianhänge in diesem Forum aktiviert sind, muss man zuerst 
ganz normal eine öffentliche Nachricht abschicken. Danach kann man den 
Anhängen-Knopf der Nachricht benutzen und so zur Dateianhangs-Seite 
gelangen. Das Schreiben einer Nachricht und das Hochladen sind auf 
diese Weise getrennt, da das Hochladen aus verschiedenen Gründen 
fehlschlagen kann, und es nicht gut wäre, wenn dabei der normale 
Nachrichtentext verlorenginge.</p>

";

#------------------------------------------------------------------------------

# Load local string overrides
do 'MwfGermanLocal.pm';

#------------------------------------------------------------------------------
# Return OK
1;
