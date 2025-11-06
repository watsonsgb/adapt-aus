Replicating Mérel & Gammans adaptation method on ABARES gridded farm data.

Historical data only with potential to try prediction but we will see.

Outcome = farm business profit/ha; weather = growing-season total rainfall; calendar-year panel; state×year clustering.

R, terra, fixest, sf, renv.

Repro: renv::restore(), then run scripts in order.

### 6 November Update ###

Data requirements
1. ABARES Gridded Farm dataset
2. SILO gridded climate data
2.1 Climatic data from 1970 - 1990 to establish "climate" for the Merel & Gamans definition of climate
2.2 Daily climatic data from 1990-2019
2.2.1 Daily rainfall
2.2.2 Temperature max
2.2.3 Temperature max