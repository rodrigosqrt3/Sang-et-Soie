# Le Sang et la Soie — Story Bible
### *Blood and Silk* · version 1.0 · 2026-10-27

> *"Ils dansaient comme si le monde n'existait plus.*
> *Il n'existait plus, en effet."*

This document is the **source of truth** for the narrative. If code, a line of dialogue or a scene contradicts it, either this document gets updated or the scene gets fixed. It merges the original design (`archive/original_design_v0.1.md`, in Portuguese) with what is already implemented in the game, and fixes the contradictions between the two (listed in section 13).

---

## 0. The story on one page

**Paris, winter 1797.** The Terror ended three years ago, but the Republic has just purged itself again: the coup of **18 Fructidor** (4 September 1797) revived the laws against émigrés. Anyone who fled France and came back on forged papers can now be tried by a military commission and shot within 24 hours.

**Étienne de Vauclaire**, 22, is an *Incroyable*: a dandy with an enormous cravat, a lead-weighted cane and a rehearsed indifference. He survived the Terror by fleeing to Spain and came back with a forged certificate of residence. His father was guillotined. His younger brother, **Théodore**, vanished during the flight and was presumed dead.

One November night, a bleeding courier stumbles into the **Bal des Victimes**, the secret ball for relatives of the guillotined where Étienne spends his nights. He dies handing over a note written in the cipher the two brothers invented as boys:

> *"Ils ont nos deux noms. Le 20 frimaire. Ne me cherche pas. — T."*
> ("They have both our names. The 20th of Frimaire. Do not look for me.")

Théodore is alive. Someone is selling, page by page, a book that links the false names of people in hiding to their real names. The pages go to **Captain Anselme Gravelot** of the Ministry of Police, who means to hand over the complete book at the Directory's great celebration for Bonaparte on **20 Frimaire (10 December)**. After that, the arrests begin. Both brothers are in the book.

Étienne has **21 nights**. To save his brother he will have to find out who Théodore is now (someone who may not want to be saved), who **inside the Bal itself** is selling the names, and what their father did in 1794 to try to save his sons.

**The question the game asks:** *what would you sell to save your own?* Every main character has already answered it. The player answers for Étienne.

---

## 1. Theme

### 1.1 The title
- **La Soie (silk)** is the mask: the Incroyable's pose, irony, survival by pretending. Silk protects and isolates. The huge cravat hides the neck, which is where the blade falls.
- **Le Sang (blood)** is the inheritance: family, the father's guilt, the brother, grief. Blood binds and wounds.

Étienne starts the game entirely in Soie. Scene by scene, the story makes him choose how much Sang he lets show. That choice is a mechanic (section 7.1).

### 1.2 The central question and each character's answer

| Character | What they sold (or sell) to save their own |
|---|---|
| **Armand de Vauclaire** (father) | The names of a friendly family, the Mirecourts, to try to save his sons. It didn't work. |
| **Dr Arvène** | The names entrusted to him, to get out of France alive. |
| **Marguerite** | The truth: she lied to Étienne for three years to protect Théodore. |
| **Théodore** | His own name. He killed "Vauclaire" so he could live. |
| **Hortense** | Her own company, offered to the man who destroyed her family, in exchange for proof. |
| **The Belgian** | Everything except a debt. Debts get paid. |
| **Gravelot** | Every regime, one after another. He is Soie taken to its end. |
| **Étienne** | The player decides. |

### 1.3 Secondary themes
- **Names are weapons.** A list kills more people than a cane. Bureaucracy is the violence that outlived the Terror.
- **Surviving is not living.** The Bal is a place where time stopped, and the question is whether anyone there truly wants to leave.
- **Brothers.** This echoes a real case: the poet **André Chénier** was guillotined in 1794, and the press accused his brother, the deputy Marie-Joseph Chénier, of failing to save him. In 1797 Marie-Joseph published a reply, the *Épître sur la calomnie*. (Used as texture in section 5.1.)

---

## 2. Writing principles

Inspired by acclaimed independent RPGs and narrative games, adapted to ours:

1. **Death moves the story forward** (*Hades*). Every failure sends Étienne back to the Bal, and the characters react to *how* and *where* he fell. Dying is never just a retry.
2. **Time is a resource** (*Pathologic*, *Majora's Mask*). There are 21 nights. Every excursion, successful or not, costs one night. The deadline is real but generous.
3. **Knowledge is progression** (*Outer Wilds*, *Return of the Obra Dinn*). Étienne's notebook (*Le Carnet*) records clues. The question "who is selling the names?" is answered **by the player**, through an accusation. The game does not hand over the answer.
4. **Inner voices** (*Disco Elysium*). Dialogue options are tagged Soie or Sang. It is the same person speaking with two voices.
5. **Real history, small people** (*Pentiment*). Historical figures appear as forces and cameos (Barras, Thérésa Tallien, Talleyrand, Bonaparte from afar), but ordinary people drive the plot. History does not change: the game happens in its cracks.
6. **Every suspect has a real secret.** Nobody is an empty red herring. Each suspect hides something serious, just not *that*.
7. **Clarity over complexity.** Each act answers one question and opens a new one (section 6.0). The player always knows *what they want to do next*, even without knowing what they will find.
8. **Show it with objects.** No expository line runs longer than three lines. Information that can live in a document, one of Céleste's drawings or one of Auguste's tunes should not live in a monologue.

---

## 3. Historical context

Everything in this section is factual. Items marked **(to verify)** must be checked against a source before they appear in game text (sources in section 12).

### 3.1 Timeline (with the Republican calendar)

| Date | Event | Use in the game |
|---|---|---|
| 1784 | The Palais-Royal opens its gardens and galleries to the public; it becomes a permanent fair of cafés, gambling, books and prostitution. | Act I |
| 7 Apr 1786 | The old quarries under the Left Bank are consecrated as the municipal ossuary: the **Catacombs**. | Act III |
| 14 Jul 1789 | Fall of the Bastille. The Faubourg Saint-Antoine supplies much of the crowd. | Act II |
| 1793 | The Palais-Royal is renamed **Palais-Égalité**. Philippe Égalité is guillotined in November. | Act I (official name) |
| 3 Nov 1793 | Philibert Aspairt, porter of the Val-de-Grâce, gets lost in the quarries. His body is not found until 1804. | Act III (rumour) |
| 1793–94 | The Terror in Bordeaux: the **Military Commission** presided over by Jean-Baptiste Lacombe condemns about 300 people. The representatives on mission are Tallien and Ysabeau. Thérésa Cabarrus, Tallien's mistress, intercedes for many prisoners. | Backstory |
| 10 Jun 1794 (22 Prairial II) | Law of 22 Prairial: the "Great Terror" begins. | Backstory |
| 14 Jun–27 Jul 1794 | The guillotine stands at the **Barrière du Trône-Renversé**, at the edge of the Faubourg Saint-Antoine. The 1,306 people executed there are thrown into mass graves in the **Picpus** garden. | Act II (the father's grave) |
| 25 Jul 1794 (7 Thermidor II) | André Chénier is guillotined at the Barrière du Trône and buried at Picpus. | The father's death (same cart) |
| 27–28 Jul 1794 (9–10 Thermidor) | Fall and execution of Robespierre. End of the Terror. | Backstory |
| 14 Aug 1794 | Lacombe is guillotined in Bordeaux. | Gravelot's backstory |
| 1794–95 | The *jeunesse dorée* and the *muscadins* beat Jacobins with canes. The Jacobin Club is closed in November 1794. | Étienne's past |
| 7 Apr 1795 | Creation of the decimal **franc**. | In-game currency |
| 7 May 1795 | Fouquier-Tinville and jurors of the Revolutionary Tribunal are guillotined. | Céleste's secret |
| 20–23 May 1795 (1–4 Prairial III) | The Prairial insurrection. The army surrounds and disarms the Faubourg Saint-Antoine. | Act II (Lucile) |
| 1795 | The former abbey of Saint-Antoine becomes a hospital. | *Requiem* ending |
| Jul 1795 | Peace of Basel with Spain. | Étienne's return |
| 1 Oct 1795 | France annexes Belgium. | The Belgian |
| 5 Oct 1795 (13 Vendémiaire IV) | A royalist rising in Paris is crushed by Bonaparte's troops. | Context |
| Oct 1795 | The **Directory** begins. | Context |
| 2 Jan 1796 | Creation of the **Ministry of General Police**. | Gravelot |
| Jan 1796 | The Directory bans the *Réveil du peuple*, the muscadins' anti-Jacobin anthem. **(to verify)** | Auguste plays the banned song |
| 31 Oct 1796 (10 Brumaire V) | Law banning British goods. | The Belgian's contraband (English muslin) |
| Jan 1797 | The police dismantle the royalist network known as the "Paris Agency". | The royalist network |
| 27 May 1797 | Babeuf is executed at Vendôme (Conspiracy of the Equals). | Act II (Saint-Antoine in mourning) |
| Jul 1797 | Talleyrand becomes Minister of Foreign Affairs. He himself had been struck off the émigré list in 1795, with the help of Germaine de Staël. | Texture ("striking off names" is power) |
| 4 Sep 1797 (18 Fructidor V) | The Directory's coup, with Augereau's troops. Elections annulled, deputies deported to Guiana, dozens of newspapers shut. The law of 19 Fructidor revives the laws against émigrés: those who returned illegally face a **military commission**. | **The engine of the plot** |
| 1797–99 | Military commissions condemn and shoot returned émigrés (in the low hundreds; exact figure to verify). | The real threat |
| 1797 | Princess Amélie of Hohenzollern-Sigmaringen secretly buys the Picpus ground where her brother is buried. **(to verify)** | Act II (detail) |
| 17 Oct 1797 | Treaty of Campo Formio. | Reason for the celebration |
| 5 Dec 1797 (15 Frimaire VI) | Bonaparte arrives in Paris. | Night 16 (the soirée) |
| **10 Dec 1797 (20 Frimaire VI)** | The Directory receives Bonaparte in an official ceremony at the **Palais du Luxembourg**, with a speech by Talleyrand. | **Night 21: the finale** |
| 9 Nov 1799 (18 Brumaire VIII) | Bonaparte's coup. End of the Directory. | Epilogue |
| 26 Apr 1802 | General amnesty for most émigrés. | Epilogue |

### 3.2 Paris in 1797: what the player feels
- **Money in everything.** Paper money (the assignats, then the *mandats territoriaux*) has collapsed, and metal coin is back. The new rich are army contractors and speculators in *biens nationaux* (property confiscated from the Church and from émigrés, sold off by the state).
- **The *politique de bascule*.** The Directory strikes alternately at the right (royalists) and the left (Jacobins) to hold the centre. That is why Arvène's book threatens both sides: nobles who came back, and sans-culottes who went into hiding after Prairial.
- **The Incroyables** wore high-collared coats, huge cravats, hair in "dog's ears" or cut *à la victime*, and a heavy knotted cane they called the *"pouvoir exécutif"*. They swallowed their r's (*"Ma paole d'honneu"*). Black collars (*collets noirs*) were a royalist sign and set off street fights with republicans.
- **The Merveilleuses** wore dresses of the finest muslin, often English, and therefore smuggled. That is why the Belgian is so welcome at the Bal.
- **The certificate of residence.** Not to be treated as an émigré, you had to prove you had never left France, with a document signed by witnesses. Forging these certificates was a trade. Getting a name struck off the émigré list (a *radiation*) was an expensive favour that could be bought. That world of papers drives the game.

### 3.3 The Bal des Victimes: fact and legend
The story went that after Thermidor, relatives of the guillotined held exclusive balls with red ribbons at the neck, hair cropped like the condemned, and a bow that mimicked the fall of a head. **Modern historians consider these balls most likely a legend** formed in the nineteenth century (see Ronald Schechter, section 12). What really existed was a sociability of traumatised survivors.

**In the game the Bal is real**, and the game itself knows it is a legend: Arvène can remark that "in fifty years no one will believe this existed". This liberty is deliberate and declared.

---

## 4. The secret history (what happened before the game)

The player discovers this gradually. Writers and designers need to know all of it now.

| Year | Event |
|---|---|
| 1775 | **Étienne de Vauclaire** is born into a family of minor nobility near Bordeaux. |
| 1779 | **Théodore** is born. The brothers grow up with a cipher of their own invention: swapped letters and an **inverted V (Λ)** as a signature. |
| 1789–92 | The family does not emigrate. The father, **Armand**, believes in constitutional monarchy. The mother dies of fever in 1791. |
| late 1793 | The uncle, **Bertrand de Vauclaire**, is arrested in Bordeaux and condemned by the Lacombe Commission. |
| early 1794 | Armand is arrested. The commission's clerk, a young man named **Anselme Gravelot**, takes his statement. To try to spare his sons, **Armand gives up the Mirecourts**, a friendly family hiding a refractory priest. Three Mirecourt brothers are executed. Hortense, the youngest, escapes thanks to Thérésa Cabarrus's intercession. |
| spring 1794 | Armand is transferred to Paris to be tried by the Revolutionary Tribunal. The sons flee south. |
| May 1794 | Near Bayonne, during a guard sweep, **the brothers are separated**. Étienne crosses into Spain and works in a stable on the Spanish side of the border. Théodore, 15, is taken in by **Madame de Rocheval**'s escape network and brought to Paris. |
| 25 Jul 1794 | Armand is guillotined at the Barrière du Trône, **in the same cart as André Chénier**, two days before Robespierre's fall. He goes into the Picpus pit. |
| 1794 | Madame de Rocheval is guillotined. **Marguerite**, her lady's companion, keeps the network going with **Dr Arvène**. |
| 1794 | In the records he takes to Paris, Gravelot logs Théodore as **dead during the flight**. To him, that makes three Vauclaires buried: Bertrand, Armand and Théodore. |
| 1795 | Arvène gives Théodore new papers: **Théo Valère**, apprentice printer in the Faubourg Saint-Antoine. Théodore decides to stay Théo. |
| Aug 1795 | After the peace with Spain, Étienne returns with a forged certificate of residence, bought from the network (so made by Arvène). Technically he is a **returned émigré**. He becomes an Incroyable, frequents the Bal and beats Jacobins with the jeunesse dorée. |
| 1796 | Marguerite tells Théodore that Étienne is alive and comes to the Bal. Théodore, who has heard what the muscadins do in Saint-Antoine, **asks her not to tell Étienne**. She obeys. |
| 1796–97 | Théo becomes the network's forger: he prints certificates of residence for anyone who needs one, whether nobles, priests or wanted sans-culottes. |
| Sep 1797 | Fructidor. Gravelot, now an inspector in the Ministry of Police's émigré bureau, discovers that Arvène forged papers. He offers a deal: **the book of correspondences (*la Table*), page by page, in exchange for a passport and passage to Philadelphia.** Or the military commission. Arvène accepts. |
| Oct–Nov 1797 | With every page delivered, a batch of people is arrested. Théodore notices his "clients" falling and starts hunting the source: he sabotages copies, steals pages, warns whoever he can. |
| 19 Nov 1797 | **The game begins.** The courier Jacquet, who works for the network, steals a page from Gravelot's copyist and carries Théodore's note to the Bal. He is wounded on the way and drops the page in the galleries of the Palais-Égalité. |

---

## 5. Characters

### 5.1 Étienne de Vauclaire — the protagonist
**22. Incroyable. A returned émigré living on forged papers.**

- **Look:** high-collared emerald-green coat (green is dangerously associated with royalists), enormous cravat, hair over the left eye, monocle, a blackened oak cane with a lead tip, and a flask of absinthe in the inner pocket.
- **Wants:** at first, nothing; that is the pose. Then, to find Théodore before 20 Frimaire.
- **Fears:** feeling. And finding out he is like his father.
- **Wound:** he let go of his brother's hand at Bayonne. He thinks he ran first.
- **Contradiction:** he hates the people who killed his family, and he spent two years beating poor people who had nothing to do with it.
- **Mechanics:** Le Regard (the monocle, which slows time and reveals ciphers); the cane; the dance-dodge; blending into crowds.
- **Possible arcs:**
  - from Soie to Sang, if he learns to be a brother;
  - from Soie to more Soie, if he becomes Gravelot;
  - or an ambiguous middle.
- **Voice (Soie):** *"Paris is a ballroom with the dead still dancing. One simply has to keep time."*
- **Voice (Sang):** *"I let go of his hand, Marguerite. At Bayonne. I have been letting go ever since."*

### 5.2 Théodore de Vauclaire / "Théo Valère"
**18. Printer and forger in Saint-Antoine.**

- To Théodore, the Revolution was a **liberation**: not from a prison, but from a name he never asked for.
- **Wants:** to protect the people whose papers he made, and to find out who is selling the Table.
- **Fears:** becoming a Vauclaire again, and his brother stands for exactly that.
- **Secret:** he knows what their father did to the Mirecourts. He read a copy of the statement in a bundle he stole from the copyist. He doesn't know whether Étienne knows.
- **Why he writes "don't look for me":** because Étienne is a well-known Incroyable who would draw the police straight to him. And because he doesn't know whether he wants his brother back.
- **Reaction to Étienne:** depends on accumulated **Violence** (section 7.3) and on the Sang choices made with him.
- **Voice:** dry, ironic, kind to others and hard on his brother. *"You came to save Théodore de Vauclaire. He died at Bayonne. I'm the one who stayed."*

### 5.3 Captain Anselme Gravelot — the antagonist
**45. Inspector in the Ministry of Police's émigré bureau. Born in Bordeaux.**

- **Biography:** a clerk's son. He was clerk to the Lacombe Commission; when Lacombe fell, he survived by handing Lacombe's papers to the Thermidorians. He has served every regime with the same precision. He is pure silk: a man who is whatever costume the regime asks for.
- **Wants:**
  - to deliver the complete Table on 20 Frimaire and be promoted to commissaire;
  - to profit by selling *radiations* to those who can pay, while handing the rest to the military commissions;
  - to close the Vauclaire file. Théodore is the **only error** in his records, and that offends him more than any crime.
- **Belief:** *"Regimes fall. Names remain. I keep the names."*
- **Relationship with Étienne:** he knows Armand's secret and uses it as a knife. He sees in Étienne someone just like himself.
- **Presence in the game:** he appears at the Bal as early as Act I, as a "guest" (he claims a relative was guillotined; it's a lie). He leads the raid on Saint-Antoine in Act II. He is the final confrontation in Act V.
- **Voice:** calm, bureaucratic, counts everything. *"I have seen three Vauclaires buried. Shall I count you twice?"* (a line already in the game, now his).
- **Weakness:** he does not understand people who are not for sale.

### 5.4 The residents of the Bal des Victimes

The Bal is in the cellar of **Madame de Rocheval**'s former hôtel, on the southern edge of the Faubourg Saint-Germain, near the rue d'Enfer. The location matters: the cellar opens onto the **quarries** of the Left Bank, which run all the way under the Luxembourg.

#### Marguerite Colbert
**38. Lady's companion to Madame de Rocheval for twenty years.**
- Speaks of Madame in the present tense: *"Madame prefers the Burgundy."* (a line already in the game).
- **Role:** keeper of the house and of the escape network; surrogate mother to everyone there.
- **Secret 1 (serious):** she hid Théodore in 1794, has known since 1796 that he is alive, and lied to Étienne for three years at Théodore's request.
- **Secret 2:** she keeps the **Livre de Madame**, the network's original register. Arvène copied it years ago to build the Table. That is what makes her the prime suspect in Act IV.
- **She is not the traitor.** She is the main red herring.
- **Arc:** she confesses in Act III. If she is wrongly accused in Act IV, she leaves the Bal, and Madame's network dies with her departure.
- **Voice:** *"Madame says secrets are like wine. Kept too long, they turn."*

#### Docteur Gaspard Arvène — the seller of names
**About 55. Physician. Laudanum addict.**
- During the Terror he wrote false sickness certificates for some thirty accused people (*"typhoid fever, unfit to appear"*). After Thermidor he moved on to certificates of residence. For safety he kept a notebook of who was who: **the Table des Correspondances**.
- **What he did:** since September he has been selling the Table to Gravelot, page by page, in exchange for a passport and passage to Philadelphia, where many French refugees lived in the 1790s.
- **Why he is understandable:** he was caught, and the alternative was a firing squad at Grenelle. He is 55, ill and afraid. He holds back the pages that cover the Bal itself, and he **anonymously warns** some people before their page is delivered. He can't stop, and he can't finish the job either.
- **Mechanical role:** he is the one who **tends to Étienne after every death**. The traitor saves the protagonist every night. His lines after deaths are the main channel for clues (section 8).
- **He must not be obvious:** he is kind, funny, drinks and knows everything. The player should like him.
- **Voice:** *"Thirty names I saved with a lie about typhus. You would think the arithmetic would let me sleep."*

#### Céleste
**13, though she looks 14.**
- Draws Paris with impossible precision and leaves the drawings folded around the ballroom.
- **How she does it:** her family's house on the rue d'Enfer had a well that opened onto the quarries (common in the district). She leaves the Bal at night and walks the city **from below**. The drawings show the places where she comes up.
- **The secret:** the Bal's rule is that you must have lost someone to the guillotine. Céleste did: her father, **a juror of the Revolutionary Tribunal**, guillotined with Fouquier-Tinville in May 1795. He sat on the jury that condemned Armand de Vauclaire. She knows.
- **Role:** guide in the quarries in Act III; source of visual clues (her drawings change every act and show things she has seen, including **Arvène at the quarry gate with a man wearing a crow signet ring**, which is Gravelot's seal); moral mirror (the daughter of a robed executioner facing the son of an informer).
- **Voice:** she barely speaks. When she does: *"Your father had nice hands. Mine said so. He said it at dinner."*

#### Auguste, the nameless musician
**Harpsichordist. Does not speak.**
- Plays the harpsichord in a corner of the ballroom every night, and the music reacts to the state of the game (a mechanic from the original design, kept in full):
  - more dissonant when a truth is close;
  - clearer after a good excursion;
  - stuck in a loop, repeating the same passage, when Étienne discovers something disturbing.
- **Secret:** he was a National Guard drummer by the scaffold. Drum rolls drowning out the last words of the condemned were a real practice, as at the execution of Louis XVI. He drummed at the Barrière du Trône executions in July 1794. He stopped speaking.
- **Plays the *Réveil du peuple*,** the muscadins' banned anthem, when he thinks nobody is listening.
- **Role in the finale:** in Act V he gives the signal with a drum roll, the only time in the game he "speaks" again through the drum.
- **Involuntary clue:** he plays one specific phrase, a Gossec minuet, every time Arvène enters the room. It is an old habit between the two. After the reveal, the player remembers.

#### Hortense de Mirecourt
**26. Former Merveilleuse.**
- White muslin (English, smuggled), short Grecian curls, gilded sandals in winter. Laughs at everything with a rehearsed lightness.
- **The unspoken history with Étienne:** the two were betrothed as children, in Bordeaux. Her three brothers were guillotined in 1794. She suspects **someone in the Vauclaire family denounced them**.
- **What she does in the game:** arrives at the Bal in Act II. She seduces Gravelot to get at the Bordeaux archives and find the original statement. That is why she is seen with him: **second suspect**.
- **Reveal (Act IV):** she gets the statement and confronts Étienne: *"Your father bought you with my brothers."*
- **Her choice in the finale:** depends on how Étienne reacts (Sang: owning the inherited guilt; Soie: denial or disdain). She can hand the Vauclaires to Gravelot out of revenge, or help.
- **Voice:** *"Darling, everyone in this room is dead. Some of us simply dress for it."*

#### The Belgian — "Monsieur Lieven"
**Ageless. Smuggler from Ghent.**
- Sells muslin, tea, cotton, gunpowder and information. Belgium has just been annexed and British goods are banned: business is excellent.
- **Secret 1:** he is the **legal owner of the hôtel**. He bought it as a bien national with smuggling money, at Marguerite's request, so that it would not be demolished. The Bal exists because he allows it.
- **Secret 2:** he pays Gravelot for protection. He knows Gravelot is buying names, but not from whom.
- **Secret 3:** he sells information to British agents (William Wickham's network, which funded royalists from Switzerland).
- **Rule of life:** debts get paid. The `smuggler_debt` **will be called in** (Act IV): he wants a document from the soirée.
- **Real name:** Lieven Coppens, revealed at high trust.
- **Voice:** *"Debts survive longer than men."* (a line already in the game) · *"I sell everything, Étienne. That is why everyone trusts me. A man who sells everything has no side."*

### 5.5 District characters

| Character | Where | Who they are | Role |
|---|---|---|---|
| **Jacquet** | Prologue | The network's courier, a former water-carrier. | Brings the note and dies. Drops the page in the Palais. |
| **Mâchefer** | Act I (quarries) | Gravelot's enforcer, a veteran of the Bordeaux revolutionary army. He was there when Armand was arrested. | Act I boss (the current sewer boss). Guards the copyist. |
| **The Copyist** | Act I | An old, short-sighted clerk who copies the Table for Gravelot. | Witness: says "the young man" (Théodore) has broken in before. |
| **Lucile Moreau** | Act II | 19, joiner's apprentice in Saint-Antoine. Her brother Jacques was arrested in the Babeuf affair; her father is in the Table (he went into hiding after Prairial). | Guide to Saint-Antoine; the voice of the people Étienne's friends used to beat. Ally or enemy depending on the Act II choice. |
| **Thérésa Tallien** (historical) | Act IV | The most famous woman in Paris, "Notre-Dame de Thermidor". She saved Hortense in Bordeaux. | Cameo: opens the door to the soirée. Being seen beside her raises Exposure. |
| **Citoyen Dufresnoy** | Act IV | Army contractor, nouveau riche, owner of a confiscated hôtel in Saint-Germain. | Host of the soirée where Gravelot receives the next-to-last page. |
| **"Monsieur de Saint-Haon"** | Acts III–V | Agent of the surviving royalist network. | Offers routes and demands loyalty. One of the exits in the *La Sortie* ending. |
| **Paul Barras** (historical) | Act V | The most powerful and most corrupt Director. | Never a direct enemy. In the finale he makes it clear Gravelot is expendable. |
| **Bonaparte** (historical) | Act V | Seen from afar at the ceremony. Never speaks. | The shadow on the horizon. |

---

## 6. Structure: prologue, five acts and epilogue

### 6.0 Overview

| Act | Title | Question of the act | Nights (approx.) | District |
|---|---|---|---|---|
| Prologue | *La Fièvre* | What is happening? | 0 | Bal |
| I | *Palais-Égalité* | What is the list and who wants it? | 1–5 | Palais-Royal → quarries |
| II | *Le Faubourg de Gloire* | Who is Théodore now? | 6–8 (fixed raid on night 8) | Saint-Antoine |
| III | *L'Empire des Morts* | Why doesn't he want to be found? | 9–12 | Quarries and Catacombs |
| IV | *Le Faubourg Saint-Germain* | Who at the Bal is selling the names? | 13–16 (fixed soirée on night 16) | Saint-Germain |
| Interlude | *Les Noms* | What to do with the time left? | 17–20 | Free excursions |
| V | *Vingt Frimaire* | What will Étienne sell? | 21 (fixed) | Luxembourg |
| Epilogue | depends on the ending | — | — | — |

**Dates:** night 0 = 29 Brumaire VI (19 Nov 1797). Night *n* = 19 Nov + *n* days. Night 8 = 7 Frimaire (27 Nov). Night 16 = 15 Frimaire (5 Dec, Bonaparte's actual arrival). Night 21 = 20 Frimaire (10 Dec).

### Prologue — *La Fièvre* (night 0)
- Étienne at the Bal, red ribbon at his neck. **Movement and conversation tutorial** inside the hub.
- First contact with every resident, one line each. Gravelot is in the room as a "guest", and Arvène treats him with an odd courtesy (**clue 0**, which nobody will notice the first time).
- **Jacquet comes down the stairs bleeding**, dies in Étienne's arms and hands over the coded note. Last words: *"The page... Égalité... the wooden galleries."*
- Étienne deciphers the note with the Regard (**monocle tutorial**).
- **Hook:** "They have both our names." The player has just learned the brother is alive and that the protagonist himself is in danger.
- **Choice (Soie/Sang):** how to react in front of the room. The first mark on the meters.

### Act I — *Palais-Égalité* (nights 1–5)
**Question:** what is this list and who wants it?

1. **The Belgian** (already implemented): says the Palais is crawling with police and offers help **in exchange for a favour**. Choices: accept the debt (`smuggler_debt`) or threaten him with the cane (Exposure). Both current lines are kept.
2. **Palais-Royal excursion** (already implemented: garden, west arcade, east arcade, secret covered passage). Recover the page **sealed in red wax with a crow**, Gravelot's seal.
3. **The page.** Twelve false names matched to real ones, with addresses. One line reads: **"Vauclaire, Étienne. Rentré. Certificat faux. Rue d'Enfer."** Étienne reads his own name. The Table even knows the Bal's address: **only an insider would** (the first clue that the seller is at the Bal, which the player doesn't have to notice yet).
4. **Reporting to the Belgian** (already implemented, with revised text): show only the seal, or hand over the page.
5. **Marguerite and the passage.** This changes what exists now: **drop the key under the floorboards**. Marguerite flinches at Théodore's name (**clue to her secret**). To get the key to the quarry door:
   - **Sang:** tell her about Bayonne. She gives him the key.
   - **Soie:** distract her and take the key. She notices later, and her trust drops.
6. **Quarry excursion** (the current "sewer" levels become the **quarries**; the layout is reused). Maintenance tunnels, the cistern/well and the copyist's chamber.
7. **Boss: Mâchefer** (the current boss, renamed; his three phases stay). New lines: *"I loaded your father on the cart myself. He was lighter than he looked."* · *"Three of you buried. The Captain hates loose ends."*
8. **The copyist** and the ledger of copies. In the margins, **Théodore's printer's corrections**: he has been sabotaging the copies, swapping letters to protect the names. *"He was never hiding from these lists. He was hunting them."* (a line already in the game).
9. **Hook:** the corrections are a professional printer's, and the type sorts come from Saint-Antoine.

**The Bal changes:** Gravelot no longer appears as a guest (he vanished after the Palais). Céleste leaves her first important drawing: the quarry gate.

### Act II — *Le Faubourg de Gloire* (nights 6–8)
**Question:** who is Théodore now?

Largely implemented already (artisans' street, closed workshop, hidden printshop). Adjustments:

1. **Arrival:** *"Silk, perfume, polished cane. In Saint-Antoine, every part of me arrives before I do."* (already in the game). **Mechanic:** in Saint-Antoine, silk does **not** let him blend into crowds. Étienne has to change clothes (buy or steal a worker's smock). The theme becomes a rule.
2. **Lucile** (already in the game). If Étienne's Violence is high, she recognises him: *"You. You were on the rue Saint-Honoré in Floréal, with the black collars. You broke my cousin's jaw."* The conversation gets more expensive.
3. **Closed workshop** (already in the game): the Λ cipher and the address behind the dyers' court.
4. **Picpus (optional):** from the courtyard you can see the wall of the Picpus garden. Étienne can stop before his father's pit. No combat, just a scene. A big Sang moment.
5. **The raid** (already in the game): Gravelot in person (*"Seal both courtyards. Take the presses, the names, and anyone whose hands smell of ink!"*). **The raid happens on night 8 no matter what.** If Étienne hasn't reached the printshop by then, it happens without him: the press is destroyed and Lucile is arrested (the worst variant, but the story goes on).
6. **The choice** (already in the game):
   - **Ring the bell and evacuate the printers:** Lucile becomes an ally, the names are saved and Théodore's trail is lost. In Act III, Lucile leads Étienne to him.
   - **Follow Théodore's trail:** Étienne learns where he is, but Lucile is arrested and Saint-Antoine closes its doors to him. In Act III, Étienne gets there first, but alone and facing a furious Théodore.
7. **The question left hanging at the Bal:** who tipped Gravelot off about the printshop? Only the people at the Bal knew where Étienne was going. Suspicion inside the house begins.

**The Bal changes:** Hortense arrives. Auguste plays more dissonantly. Marguerite avoids Étienne.

### Act III — *L'Empire des Morts* (nights 9–12)
**Question:** why doesn't Théodore want to be found?

1. **Céleste as guide:** she knows the quarries and leads Étienne along paths only a child who climbs down her own well could know. **Céleste's reveal** happens on the way down (her juror father). Sang/Soie choice: how Étienne takes it.
2. **The Catacombs:** walls of bones; Étienne can find a lantern with the initials "P.A." and hear the *carriers* (quarrymen) tell the rumour of the porter lost in 1793. The body is not found, because historically that only happened in 1804.
3. **The reunion.** Théodore's network meets in an ossuary. It is the central scene of the game. His reaction depends on:
   - accumulated Violence;
   - the Act II choice;
   - earlier Sang choices.

   What happens in the scene:
   - Théodore reveals that **Marguerite has known about him for three years**.
   - Théodore asks whether Étienne **knows what their father did to the Mirecourts**. Étienne doesn't. Théodore shows him the copy of the statement.
   - Théodore concludes that the source of the Table is at the Bal: the page holds details only Madame's network knew.
4. **Gravelot's ambush** in the ossuary (a chase, not a boss). The brothers are separated again; the echo of Bayonne is deliberate. This time **the player can choose to hold on**: with high Sang, Étienne gets hurt covering Théodore's escape, and that shapes the ending.
5. **Marguerite's confession** at the Bal, on the way back.

**Hook:** *"The traitor is among us."* The Carnet opens its **"Who is selling the names?"** section.

**The Bal changes:** the mood turns suspicious, and every character gets an interrogation dialogue.

### Act IV — *Le Faubourg Saint-Germain* (nights 13–16)
**Question:** who at the Bal is selling the names?

1. **Investigation at the Bal** (no combat): interrogations, drawings, Auguste's music, the Belgian's books (at high trust). Details in section 8.
2. **The Belgian calls in the debt:** he wants a document from the soirée (the price list of *radiations*, signed by a Director's secretary). Doing it or refusing changes Act V.
3. **Citoyen Dufresnoy's soirée** (night 16, **fixed date**: the night Bonaparte arrives in Paris). A social infiltration stage: silk is camouflage again. Thérésa Tallien opens the door, Hortense is on Gravelot's arm, and Gravelot receives the next-to-last page from a go-between. Étienne follows the go-between or the envelope.
4. **Hortense finds the statement.** Confrontation (*"Your father bought you with my brothers."*). Sang/Soie choice.
5. **The accusation** (back at the Bal): the player picks **who**, **why** and **how**.
   - **Correct (Arvène + coerced by Gravelot + via Jacquet and the quarry gate):** the confession scene, *"can you understand?"*. Choices:
     - **Forgive him and use him:** Arvène forges a counter-intelligence page for Act V.
     - **Hand him to the network:** he disappears, and nobody knows what they did with him.
     - **Let him leave for Philadelphia:** he leaves the last page to Étienne.
   - **Wrong:** the innocent person pays (Marguerite leaves, Hortense breaks with him, or the Belgian cuts his credit), and Arvène delivers the last page. Act V gets harder, but the story goes on.

### Interlude — *Les Noms* (nights 17–20)
- The remaining nights can be spent **saving names** from the Act I page: twelve people, twelve short missions (warn them, swap their papers, get them out of Paris). Each name has a 2–3 line vignette: a refractory priest, a former Jacobin from Prairial, a former countess who now sells hats, Lucile's father...
- This is where the **roguelite loop** meets the narrative: repeatable content that **means** something.
- **`names_saved` counter (0–12):** shapes the epilogue.
- Players who died a lot earlier have fewer nights here. The deadline becomes a moral choice: save strangers or prepare the final move.

### Act V — *Vingt Frimaire* (night 21, 10 December 1797)
**Question:** what will Étienne sell?

1. The Directory's official ceremony for Bonaparte at the **Palais du Luxembourg** (fact). Crowds, troops, speeches, Talleyrand.
2. **Entry from below:** the quarries reach under the Luxembourg (geographic fact). This is the payoff for all the underground map built in earlier acts. Soie alternative: walk in the front door with Thérésa's invitation, at a cost in Exposure.
3. **Allies present** depending on what has accumulated: Lucile and the printers, Céleste, Auguste (the signal drum roll), Hortense (if she helps), the Belgian (if the debt was paid), Arvène (if he was forgiven).
4. **Confronting Gravelot:** it doesn't have to be a cane fight. It can be resolved:
   - through Exposure (showing the price list to Barras);
   - through Soie (a bluff, the duel of masks);
   - through Sang (Armand's statement: Étienne owns his father's guilt out loud and takes away Gravelot's weapon).

   Barras sacrifices Gravelot without blinking if it suits him. Consistent with history: the Directory lived on scapegoats.
5. **The Table in Étienne's hands. The final choice:**
   - **Burn** the book.
   - **Print** the price list with Théodore, exposing the corruption. The names stay protected, but the Vauclaires are exposed and must flee.
   - **Give it to the Belgian** (pays the debt; he sells it to the British).
   - **Trade** the Table to Barras for both Vauclaire names struck off the list. Everyone else pays.

---

## 7. Narrative systems

### 7.1 Soie / Sang (Étienne's voice)
- Dialogue options are tagged **[Soie]** (irony, mask, deflection, charm, elegant threat) or **[Sang]** (sincerity, memory, grief, guilt, tenderness). Some options are neutral.
- Two separate counters (`soie` and `sang`), **not** a single bar. An Étienne can be a lot of both.
- **Effects:**
  - **Sang** opens up the trust of Théodore, Marguerite and Lucile, and the *La Sortie* ending;
  - **Soie** opens up salons, social camouflage, the duel of masks with Gravelot and the *La Soie* ending.
- The UI can colour the tags: silk in green and gold, blood in burgundy.

### 7.2 Exposure (already exists: `exposure`)
How much the police know about Étienne.

| Exposure | State | Consequences |
|---|---|---|
| 0–2 | discreet | Normal. |
| 3–5 | noticed | More guards per room; the Belgian charges more; Bal guests avoid Étienne. |
| 6+ | hunted | Gravelot's agents show up during excursions; a raid event hits the Bal itself (for the first time, the hub is not safe). |

### 7.3 Violence (already exists: `violence`)
How often Étienne solves things with the cane. **Violence never pays** (a rule already implemented in the code, and a good one).
- Affects Théodore and Lucile (greeting, trust, ending), and Auguste (who plays the *Réveil du peuple* when Étienne returns from a violent excursion: the muscadins' song as a mirror).
- The **"Weighted Cane"** upgrade is called ***"Pouvoir exécutif"*** in game. The temptation carries its historical name.

### 7.4 The Calendar (21 nights)
- Every excursion uses up one night, success or failure.
- **Fixed dates:** night 8 (the Saint-Antoine raid), night 16 (the soirée), night 21 (the celebration).
- The main path without failures takes about 12 nights, leaving about 9 for failures and *Les Noms*.
- Reaching night 21 without finishing Act IV leads straight to the *Requiem* ending.
- **Balance:** the deadline should never punish an average player. It exists to add weight, not to cause game overs.

### 7.5 Death and the return to the Bal (*Hades*)
- **It is not supernatural.** When Étienne falls, the network carries him back through the tunnels: sometimes Céleste, sometimes the *carriers*, sometimes a thief paid by the Belgian. He wakes at the Bal, on a camp bed, **with Arvène tending to him**.
- **Cost:** the night, part of his coins and +1 Exposure (already implemented in `record_failed_run`).
- **Death dialogue:** Arvène remarks on *where* and *how* Étienne fell, and each remark can hide a clue. Example: after a fall in the quarries, *"The quarry gate again? You'll wear out the hinges. ...Never mind. Drink this."* Later it turns out he uses that gate himself.

### 7.6 Le Carnet (the notebook)
- Automatically records names, clues, collected drawings and contradictions.
- A **"Who is selling the names?"** section from Act III onward, with suspect files.
- The final accusation is **made inside the Carnet** (*Obra Dinn* style: fill in who, why and how).

### 7.7 The debt to the Belgian (already exists: `smuggler_debt`)
Called in during Act IV (the soirée document). If paid, he offers the escape route for the *La Sortie* ending. If not, he collects in Act V, at the worst possible moment.

### 7.8 Names saved (`names_saved`, 0–12)
They count in the epilogue. Each saved name becomes a line in the final credits. In the *La Soie* credits, the names that were **not** saved appear struck through.

---

## 8. The mystery: who is selling the names?

### 8.1 The answer
**Arvène.** Coerced by Gravelot after Fructidor, in exchange for a passport and passage to Philadelphia. He uses Jacquet and the quarry gate to deliver the pages.

### 8.2 The real clues (the player needs at least 4 to be sure)
1. **Prologue:** Arvène greets Gravelot, the "guest", as if he already knew him.
2. **The Act I page carries medical details** ("dit malade, fièvre typhoïde, 1794") that only the man who wrote the certificates would know.
3. **Arvène's name is not in the Table.** He forged dozens of papers and should be the first name in the book. The absence is the strongest clue, and the hardest to notice.
4. **The smell of laudanum on Jacquet's coat** (description when examining the body in the prologue). Arvène is the only laudanum user at the Bal.
5. **Céleste's Act III drawing:** a man in a physician's coat at the quarry gate, with a man wearing a crow ring.
6. **The Belgian's books** (at high trust): passage on an American ship from Le Havre to Philadelphia, ordered "by a gentleman whose hands shake".
7. **The death remarks** (section 7.5) about the quarry gate.
8. **The music:** the Gossec minuet Auguste plays whenever Arvène enters. It only becomes a clue when the player decides to pay attention.
9. **The printshop was betrayed** (Act II) after Étienne told the Bal where he was going. Arvène was in the room; Hortense, another suspect, had not yet arrived at the Bal.

### 8.3 The red herrings (each with a real secret)

| Suspect | Why they look guilty | What they really hide |
|---|---|---|
| **Marguerite** | Keeps the Livre de Madame, which the Table seems to come from; lied about Théodore. | Théodore's secret. |
| **Hortense** | Seen with Gravelot; takes money from him; has a motive to hate the Vauclaires. | She is seducing Gravelot to find the statement. |
| **The Belgian** | Sells everything; owns the building; pays Gravelot. | Paid protection and spying for the British. |
| **Céleste** | Slips out in secret; her father was a Tribunal juror. | She walks the city from below and draws. |

### 8.4 Rules of the mystery
- **Every clue appears at least twice** (in different places, in different forms).
- **A wrong accusation never blocks the game**; it only costs something.
- **The player can accuse early** if already convinced.

---

## 9. The endings

Decided by **accumulated** play, not by a single choice. The Table choice (Act V) selects among the endings that are **available**.

| Ending | Conditions | What happens |
|---|---|---|
| ***Requiem*** | Calendar runs out **or** Théodore's trust is broken (high Violence + dominant Soie with him + "follow Théodore" in Act II with no repair). | Étienne arrives too late. Théodore lies wounded in the hospital in the old Saint-Antoine abbey. *"I knew you would come. I just didn't know if I wanted you to."* Étienne stays. The game doesn't show what comes after. |
| ***Le Bal Continue*** | Act IV resolved + Table **burned** + medium trust from Théodore. | The names are safe, for now. Théodore stays Théo. The brothers talk through one whole night, and in the morning he goes to work. Étienne returns to the Bal and sits beside Auguste. The camera pulls back. *The ball goes on.* |
| ***La Sortie*** | **High** trust from Théodore (Sang) + a secured escape route (the Belgian with the debt paid, Thérésa or Saint-Haon) + Table **printed** or **burned**. | The brothers flee together. The last stage is getting out of Paris, linear and tense. They look back at Paris from a distance, their backs to the camera. Only the wind. *They got out. Nothing waits for them on the other side.* |
| ***La Soie*** (dark ending) | Choosing to **trade** the Table to Barras for the Vauclaire names. | Étienne is struck off the list and becomes an Incroyable *comme il faut*. He goes to the celebration and dances. Auguste stops playing. In the credits, the unsaved names are struck through one by one. Théodore never forgives him, or never finds out, depending on what has accumulated. |

**Variations within each ending:** Hortense (took revenge or forgave), Arvène (left, vanished or stayed), Lucile (free or imprisoned), `names_saved`, Marguerite (at the Bal or gone).

### Historical epilogue (common to all endings)
Text cards on a black background:
- *"18 Brumaire, Year VIII (9 November 1799). General Bonaparte overthrows the Directory."*
- *"26 April 1802. A general amnesty allows most émigrés to return home."*
- Variable: *"The names you saved in 1797 could have come home."* or *"Some of the names you did not save would have been pardoned in four years."*

---

## 10. The Bal over the course of the game (hub reactivity)

| Moment | Changes |
|---|---|
| Prologue | Everyone present; Gravelot as a guest; Jacquet dies on the stairs. |
| Act I | Gravelot is gone; Céleste's first drawing (the gate). |
| Act II | Hortense arrives; Auguste more dissonant; Marguerite avoids Étienne. |
| Act III | Marguerite confesses; the drawing of Arvène appears; an atmosphere of suspicion. |
| Act IV | Interrogations; the Belgian calls in the debt. After the accusation, the chair of whoever left stays empty. |
| Exposure 6+ | Event: a police raid on the Bal. |
| After every death | A short scene with Arvène. |
| High Violence | Auguste plays the *Réveil du peuple*; Marguerite grows colder. |

---

## 11. Style guide

### 11.1 Tone
Elegant melancholy, dry humour and sudden violence. Never melodrama: characters say less than they feel. The joke is armour, and you can tell.

### 11.2 Voices

| Character | Register |
|---|---|
| Étienne (Soie) | Short, cynical sentences; Incroyable superlatives (*incroyable*, *merveilleux*); now and then he swallows his r's (*"Ma paole d'honneu"*), **sparingly**: at most once per scene. |
| Étienne (Sang) | Plain sentences, no adjectives. |
| Théodore | Practical and acid; trade vocabulary (type, press, ink). |
| Gravelot | Numbers, dates, full names. Never raises his voice. |
| Marguerite | Madame in the present tense; household proverbs. |
| Arvène | A doctor's humour, misquoted Latin, self-deprecation. |
| Hortense | Lightness and venom; "darling". |
| The Belgian | Commerce; everything has a price; French with Flemish turns of phrase. |
| Lucile | Direct, no ceremony, righteous anger. |
| Céleste | Almost mute; childlike sentences with terrible content. |
| Auguste | Music only. |

### 11.3 Rules
- Expository lines: at most **3 lines** per dialogue box.
- Period French terms in italics, untranslated when context is enough (*sans-culotte*, *muscadin*, *radiation*, *certificat de résidence*).
- **Dates in the Republican calendar** in game (*"20 Frimaire"*), with the Gregorian equivalent in the Carnet.
- Real historical figures speak little and never say anything that contradicts the historical record.

---

## 12. Sources

- **Louis-Sébastien Mercier, *Le Nouveau Paris* (1798):** a contemporary description of Directory Paris. A primary source, excellent for texture.
- **Ronald Schechter, "Gothic Thermidor: The *Bals des victimes*, the Fantastic, and the Production of Historical Knowledge in Post-Terror France"**, *Representations* 61 (1998). On the legend of the Bal.
- **François Gendron, *La Jeunesse dorée* (1979).** On the muscadins.
- **Howard G. Brown, *Ending the French Revolution: Violence, Justice, and Repression from the Terror to Napoleon* (2006).** On the military commissions and post-Fructidor repression.
- **Isser Woloch, *Jacobin Legacy: The Democratic Movement under the Directory* (1970).** On Saint-Antoine and the neo-Jacobins.
- **Colin Jones, *The Fall of Robespierre* (2021).** On Thermidor.
- **Denis Woronoff, *La République bourgeoise* (1972).** An overview of the Directory.
- For music: François-Joseph Gossec, Étienne Méhul, Luigi Cherubini (already in the original design).

---

## 13. Historical liberties and corrections from v0.1

### 13.1 Deliberate liberties (fiction over fact)
- **The Bal des Victimes exists** (most likely a legend; see 3.3).
- The Vauclaire family, the Mirecourts, Madame de Rocheval, Gravelot, Arvène and the Table are **fictional**, built on real mechanisms: military commissions, émigré lists, forged certificates and bought *radiations*.
- **The Dufresnoy soirée** is fictional, but its date (Bonaparte's arrival) is real.
- **Fouché** appeared in the original design as a minister with agents. In 1797 he was **not yet** Minister of Police (he only became one in July 1799). If he appears, it should be as an intriguer in Barras's service, or mentioned by an agent who "claims to work for citizen Fouché".

### 13.2 Corrections from the original design
- **Ages:** v0.1 had Étienne at 16 in 1794 and 22 in 1797, which is impossible. Now: 19 in 1794 and 22 in 1797. Théodore: 15 in 1794 and 18 in 1797.
- **"Six years since the separation":** it is three (1794 → 1797).
- **"Madame de Rémusat"** was replaced with **Madame de Rocheval**, because Madame de Rémusat is a real person (the memoirist Claire de Rémusat), alive at the time.
- **"Six million dead" in the Catacombs:** that number is the total accumulated by the mid-nineteenth century. In 1797 there were far fewer. In game we say "millions", without a number.
- **The trigger:** in v0.1 the note was handed over in a Palais-Royal tavern. Now it reaches the Bal in the prologue, carried by Jacquet, and the Palais-Royal search (already implemented) is for the page he dropped.
- **"November":** kept. The game starts on 29 Brumaire VI (19 November 1797), after Fructidor, which provides the concrete legal threat.
- **The sewers** in the current code become **the quarries/Catacombs** (historically more coherent under the Left Bank). The current boss, the **Captain**, becomes **Mâchefer**, and the title "Captain" goes to Gravelot.

---

## 14. From this document to the code

### 14.1 What exists and where it fits

| Current code | In the new story |
|---|---|
| `QUEST_TALK_TO_SMUGGLER` → `QUEST_REPORT_FRAGMENT` | Act I, steps 1–4 (kept, with revised text). |
| `QUEST_TALK_TO_MARGUERITE` / `QUEST_GRAB_KEY` | Act I, step 5 (the key under the floorboards goes; the Sang/Soie choice comes in). |
| `QUEST_ENTER_SEWERS`, the `sewer_*` levels, `boss.gd` | Act I, steps 6–8: the quarries and Mâchefer. |
| `dossier.gd` (the ledger) | The copyist's ledger with Théodore's corrections. |
| All of Chapter II (`saint_antoine/`) | Act II (kept; adds the change of clothes, Picpus, the fixed date and the variants). |
| `exposure`, `violence`, `smuggler_trust`, `smuggler_debt` | Kept, and **finally read** by the game (section 7). |
| Death → `record_failed_run` → Bal | Kept; adds Arvène's dialogue and the cost of a night. |
| Auguste (just a rectangle today) | Becomes a character with reactive music. |

### 14.2 What needs to be built (next steps)
1. **Narrative state as data:** `flags` and `counters` in a dictionary (`soie`, `sang`, `night`, `names_saved`, `theodore_trust`...), instead of one variable per consequence.
2. **Dialogue as data:** nodes with conditions, effects and N options tagged Soie/Sang.
3. **The Calendar** and fixed-date events.
4. **Le Carnet** (the clue and accusation UI).
5. **A reactive hub** per act.
6. **New districts:** the Catacombs (Act III), Saint-Germain (Act IV), the Luxembourg (Act V), which calls for the code-driven **LevelBuilder** to build rooms quickly and symmetrically.

---

*Le Sang et la Soie · Story Bible v1.0*
*Supersedes the original design v0.1 (archived in `docs/archive/`).*
