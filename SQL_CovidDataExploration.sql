/* Data Exploration */

-- Select the data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM First_Portfolio_Project..CovidDeaths
ORDER BY 1, 2


-- Looking at TotalCases vs TotalDeaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM First_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL -- meaning the location doesn't have continent names
ORDER BY 1, 2

-- Looking at death percentage in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM First_Portfolio_Project..CovidDeaths
WHERE location LIKE '%India%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at total cases vs Poplation, determining how many people had covid in the entire population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM First_Portfolio_Project..CovidDeaths
WHERE location LIKE '%India%' AND continent IS NOT NULL
ORDER BY 1, 2


-- Looking at highest infection rate compared to population of various countries/locations
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS MaxInfectionPercentage
FROM First_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxInfectionPercentage	DESC



-- Looking at countries with highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS MaxDeaths
FROM First_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeaths	DESC


-- Grouping up maximum deaths by continents
SELECT location, MAX(CAST(total_deaths AS INT)) AS MaxDeaths -- using location as numbers are more accurate as compared to using continents
FROM First_Portfolio_Project..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY MaxDeaths	DESC


-- Looking at global numbers in DeathPercentage according to date
SELECT date, SUM(new_cases) AS GlobalNewCases, 
       SUM(CAST(new_deaths AS INT)) AS GlobalNewDeaths, 
	   (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 GlobalDeathPercentage
FROM First_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Total deaths globally
SELECT SUM(new_cases) AS GlobalNewCases, 
       SUM(CAST(new_deaths AS INT)) AS GlobalNewDeaths, 
	   (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 GlobalDeathPercentage
FROM First_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL



--=============================================================================================================================================
-- Combining Deaths and vaccinations
SELECT * 
FROM First_Portfolio_Project..CovidDeaths deaths
JOIN First_Portfolio_Project..CovidVaccinations vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date

-- Looking at total populations vs vaccinations across countries
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
FROM First_Portfolio_Project..CovidDeaths deaths
JOIN First_Portfolio_Project..CovidVaccinations vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2, 3


-- Looking at rolling count of total populations vs vaccinations across countries
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations,
		SUM(CONVERT(INT, vaccine.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
		AS RollingVaccinatedPopulation

FROM First_Portfolio_Project..CovidDeaths deaths
JOIN First_Portfolio_Project..CovidVaccinations vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2, 3


-- Looking at rolling vaccinated population percentage across countries
WITH PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedPopulation)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations,
		SUM(CONVERT(INT, vaccine.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)
		AS RollingVaccinatedPopulation

FROM First_Portfolio_Project..CovidDeaths deaths
JOIN First_Portfolio_Project..CovidVaccinations vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (RollingVaccinatedPopulation/Population)*100 FROM PopulationVsVaccination AS RollingVaccinatedPercentage




--==============================================================================================================================================
-- Creating views for visualisations
CREATE VIEW VaccinatedPopulationPercentage AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
FROM First_Portfolio_Project..CovidDeaths deaths
JOIN First_Portfolio_Project..CovidVaccinations vaccine
	ON deaths.location = vaccine.location
	AND deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL

SELECT * FROM VaccinatedPopulationPercentage

