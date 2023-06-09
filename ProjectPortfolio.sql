SELECT * FROM CovidDeaths
ORDER BY 7
;

SELECT * FROM CovidVaccinations
ORDER BY 3,4
;

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 3) AS mortality
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2
;


ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float
;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float
;

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 3) AS infection_rate
FROM CovidDeaths
WHERE location = 'China'
ORDER BY 3 DESC
;

SELECT location, population, MAX(total_cases) AS total_cases 
,ROUND(MAX((total_cases/population))*100, 3) AS infection_rate
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC
;

SELECT location, population, MAX(total_deaths) AS total_deaths 
,ROUND(MAX((total_deaths/population))*100, 3) AS infection_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 2 DESC
;

SELECT continent, MAX(total_deaths) AS total_deaths 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC
;

SELECT date, SUM(new_cases) AS Agg_Cases, SUM(new_deaths) AS Agg_deaths
, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 3) AS mortality
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases > 0
GROUP BY date
ORDER BY 1
;

SELECT * FROM CovidDeaths
SELECT * FROM CovidVaccinations
;

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations FLOAT
;

WITH Pop_Vac (continent, location, date, population, new_vaccinations, agg_vaccinations)
AS
(
SELECT cv.continent, cv.location, cv.date, cv.population, cd.new_vaccinations
		, SUM(cd.new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date) AS agg_vaccinations
FROM CovidDeaths AS cv
	JOIN CovidVaccinations AS cd
	ON cv.iso_code = cd.iso_code
	AND cv.date = cd.date
WHERE cv.continent IS NOT NULL 
--ORDER BY 2,3
)

SELECT *, (agg_vaccinations/population)*100 AS vaccination_rate
FROM Pop_Vac
WHERE location = 'Nigeria'
ORDER BY 3
;


DROP TABLE IF EXISTS #Population_Rate
CREATE TABLE #Population_Rate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
agg_vaccinations numeric
)

INSERT INTO #Population_Rate
SELECT cv.continent, cv.location, cv.date, cv.population, cd.new_vaccinations
		, SUM(cd.new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date) AS agg_vaccinations
FROM CovidDeaths AS cv
	JOIN CovidVaccinations AS cd
	ON cv.iso_code = cd.iso_code
	AND cv.date = cd.date
WHERE cv.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, agg_vaccinations/Population AS vaccination_rate
FROM #Population_Rate
WHERE Location = 'Nigeria'
ORDER BY Date
;


CREATE VIEW Population_Rate AS
SELECT cv.continent, cv.location, cv.date, cv.population, cd.new_vaccinations
		, SUM(cd.new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date) AS agg_vaccinations
FROM CovidDeaths AS cv
	JOIN CovidVaccinations AS cd
	ON cv.iso_code = cd.iso_code
	AND cv.date = cd.date
WHERE cv.continent IS NOT NULL
;