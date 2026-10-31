# Le Sang et la Soie — Art Direction
### version 0.1 · 2026-10-27

Companion to [story_bible.md](story_bible.md). This defines how the world and its people look. Like the bible, it is a living document.

**Reference moodboard:** `docs/reference/galliano/` (local only, not in the repository; the images are copyrighted). File names below refer to that folder.

---

## 1. Why Galliano

John Galliano's 1984 graduate collection at Central Saint Martins was called *Les Incroyables*. His work has returned to the Directory-era dandy ever since. That is useful to us for one reason: Galliano never makes a costume reconstruction. He takes the **gestures** of 1797 and makes them feel alive, dangerous and slightly wrong. The game wants the same thing: history that feels like it is happening now.

We take his **silhouette, colour and attitude**, not his garments. A latex legging is not 1797; the *idea* behind it (breeches so tight they read as a second skin, scandalously) is.

---

## 2. The visual language (what we take from the references)

### 2.1 Silhouette
- **Oversized outer layer, narrow legs.** Huge-shouldered coats with long tails over skin-tight legs (`incroyables_latex_breeches.jpg`, `quartet_fur_hems_red_gaiters.jpg`). It reads as an inverted triangle. **This is the Incroyable silhouette, and it must read at 40 pixels tall.**
- **The neck is always armoured.** High stocks, white cravats knotted with satin, collars up to the ears (`closeup_white_stock_fur.jpg`, `closeup_red_satin_cravat.jpg`, `bal_black_stocks_group.jpg`). Historically, the cravat hides the neck the guillotine cuts. **Every Bal character covers the neck. Gravelot doesn't need to.**
- **Soft, crushed bicornes and cloches**, never stiff military hats (`pair_bicorne_lace_jabot.jpg`).
- **Hair as volume.** Merveilleuses: enormous frizz, as if blown by something (`merveilleuse_black_tulle.jpg`). Incroyables: "dog's ears" curls framing the face and hiding one eye.

### 2.2 Details that carry meaning
- **The cockade.** Pleated ribbon rosettes on every hat, in gold and black (`closeup_gold_cockade.jpg`), olive and gold (`closeup_olive_cockade_gingham.jpg`). In 1797 a cockade is a political statement (the tricolour is required by law). **In game, cockade colour is faction language:** tricolour on police and soldiers, black (royalist) hidden inside hats at the Bal, none on Théodore.
- **Red satin at the throat** (`closeup_metallic_lips_red_cravat.jpg`). It echoes the red ribbon of the Bal des Victimes. Étienne's cravat ribbon is red.
- **Red gaiters/stockings over black shoes** (`quartet_fur_hems_red_gaiters.jpg`). A strong, cheap identifier for the jeunesse dorée.
- **Fur at the edges:** collars and hems (`emerald_satin_fur_coat.jpg`). It reads as wealth and as animal.
- **Gloves as character:** sheer tulle (Hortense), mint opera gloves (salons), gingham work gloves (Céleste, Marguerite's household), rust leather (Lucile).
- **Layers visible through layers:** lingerie over garments, tulle over satin (`teal_satin_over_tulle.jpg`). The Merveilleuses' *robes de chair* were real; the transparency is period-correct.

### 2.3 Faces
- **Pallor and red-rimmed eyes.** Everyone at the Bal looks sleepless, feverish, in mourning (`closeup_burgundy_lips_frizz.jpg`).
- **Blue lips** (`closeup_blue_lips_black_stock.jpg`, `closeup_metallic_lips_pair.jpg`): the colour of the drowned and the strangled. **Proposal (an invented ritual, not historical):** at the Bal, the guests paint their lips the colour of the dead. Étienne has blue lips only at the Bal; on the street, his lips are normal. It is a small, visible line between the two worlds.

### 2.4 Attitude and pose
Nobody stands straight. Bodies lean, hang off each other, break at the wrist, bend backwards (`jewel_leather_group.jpg`, `trio_pinstripe_straw_bicorne.jpg`). It is a slow-motion *danse macabre*. For animation:
- idle poses are languid and off-balance;
- the dodge is a dance step (already in the original design);
- characters touch each other a lot at the Bal, and nobody touches anyone on the street.

---

## 3. Palette

Three registers, each with a purpose.

| Register | Where | Colours | Reference |
|---|---|---|---|
| **Le Bal (night)** | Hub | Black, sheer black, bone white, candle gold; blue lips as the only cold note | `bal_black_sheer_group.jpg`, `bal_black_stocks_group.jpg` |
| **La Soie (jewels)** | Accents on Bal characters, salons, Act IV–V | Emerald/teal, violet, mustard/ochre, burgundy, rust | `jewel_leather_group.jpg`, `purple_orange_lace_dress.jpg` |
| **Le Pavé (street)** | Districts | Herringbone grey, mud brown, olive, faded gingham blue, oil-lamp yellow | `olive_herringbone_rust_gloves.jpg`, `editorial_street_dandy.jpg` |

**Rule:** jewel colours mean *silk*. On the street they are always out of place, which is the point (the story bible already says Étienne's emerald coat clashes with Paris). The more jewel colour a character wears in a district, the more they are noticed. This could feed the crowd-blending mechanic directly.

Suggested starting values (to tune in game):

| Name | Hex | Use |
|---|---|---|
| Bal black | `#0E0B0D` | Hub background, Bal clothing |
| Bone | `#E9E2D3` | Cravats, stocks, portrait backdrop |
| Candle | `#E0A84A` | Light, cockade gold |
| Dead blue | `#4F7FC4` | Bal lips |
| Emerald | `#1F6B5A` | Étienne |
| Violet | `#6A3A8C` | Hortense, salons |
| Ochre | `#B8922E` | Merveilleuse accents |
| Burgundy | `#6E1E2B` | Blood, the red ribbon (darker) |
| Ribbon red | `#B3202C` | Cravat ribbons, gaiters |
| Rust | `#A5532A` | Saint-Antoine, Lucile |
| Herringbone | `#4A4744` | Street clothing |
| Olive | `#5E6340` | Workers, Marguerite |
| Mud | `#3A2C22` | Street ground |

---

## 4. Character sheets (first pass)

| Character | Silhouette idea | Key pieces | Palette | References |
|---|---|---|---|---|
| **Étienne** | Inverted triangle: huge emerald coat with long tails, very narrow dark legs. | Soft black bicorne with a hidden black cockade; white stock knotted with **red satin**; dog's-ear curls over the left eye; lead-tipped cane; red gaiters. Blue lips only at the Bal. | Emerald, bone, ribbon red, black | `incroyables_latex_breeches.jpg`, `closeup_white_stock_fur.jpg`, `emerald_satin_fur_coat.jpg` |
| **Théodore** | The opposite of his brother: compact, practical, sleeves rolled, no tails. | Crushed felt hat, worker's smock, knitted cuffs, ink-black hands, no cravat (**an open neck, the only one among the Vauclaires**), no cockade. | Mud, herringbone, ink black | `editorial_street_dandy.jpg` |
| **Gravelot** | Straight, vertical, closed. The only body that does not lean. | Sober grey coat, tricolour cockade, crow signet ring, a neat ledger. Zero excess. | Grey, tricolour (small) | *Deliberately not Galliano.* He is the absence of silk. |
| **Marguerite** | Respectable, layered, rounded. | Black cloche with gold-and-black cockade, herringbone coat, olive collar, burgundy lips, gingham work gloves. | Black, olive, herringbone, burgundy | `olive_herringbone_rust_gloves.jpg` (left), `closeup_olive_cockade_gingham.jpg` |
| **Dr Arvène** | Heavy, slumped, belted. | Oversized black coat with a fur collar, grey lace jabot gone limp, laudanum bottle. | Black, grey lace, fur brown | `pair_bicorne_lace_jabot.jpg` (right), `vinyl_trench_opera_gloves.jpg` |
| **Hortense** | Vertical frizz, transparent body. | Huge frizzy hair, sheer black tulle dress with ruffles, mint opera gloves, blue metallic lips. | Black tulle, violet, mint | `merveilleuse_black_tulle.jpg`, `closeup_mint_opera_glove.jpg`, `purple_orange_lace_dress.jpg` |
| **Céleste** | Small, inside clothes too big for her. | An adult's coat, gingham gloves, frizzy hair, paper drawings in her pockets. | Herringbone, faded blue | `herringbone_gingham_gloves.jpg` |
| **Auguste** | Pure black, rigid. | Deconstructed black jacket, black stock tied very high, as if he were gagged. | All black | `bal_black_stocks_group.jpg` (right) |
| **The Belgian** | Wide, layered with contraband. | Camel trench with a fur collar, burgundy cardigan, pinstripe trousers with a side stripe, a holster, a bag of English muslin. | Camel, burgundy, pinstripe | `trio_camel_trench_holster.jpg` (centre) |
| **Lucile** | Working body, strong stance. | Olive work dress, rust leather gloves, sleeves pushed up, sawdust. | Rust, olive | `olive_herringbone_rust_gloves.jpg` (right) |

---

## 5. From reference to the game

### 5.1 Two scales
- **In the world (top-down, small):** characters must read by **silhouette and 2–3 colour blocks**. Detail is wasted here. The inverted triangle, the hat shape, one jewel colour and the red at the throat are enough to recognise Étienne.
- **In dialogue (portraits, large):** this is where the fashion lives. Proposal: portraits framed like these photographs, on a flat **bone-white** backdrop, chest-up and slightly tilted. The Bal becomes a fashion shoot of the dead. Strong contrast with the dark game world, and very recognisable.

### 5.2 Built from code
Since we want to work in code, characters can be **layered paper dolls**: each one is data (coat shape, collar height, hat, hair volume, palette) drawn with `Polygon2D` and `Line2D` layers. Advantages:
- they are symmetric and consistent by construction (no hand-placed rectangles);
- NPC variety comes from parameters (a crowd of 20 different Merveilleuses for free);
- costume changes (Étienne's worker smock in Saint-Antoine) are a data swap, which ties directly to the story mechanic;
- the art can be replaced later by drawn sprites without touching gameplay.

### 5.3 Open questions
- **Camera:** stay pure top-down, or move to a 3/4 view (like *Hades*) so silhouettes and coats show? 3/4 suits the fashion much better.
- **Portraits:** code-drawn vector, or hand-drawn/commissioned illustration later? Either way, the white-backdrop framing stays.
- **The blue-lips ritual:** keep it? (It would need one line in the story bible.)
