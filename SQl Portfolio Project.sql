SELECT * FROM Portfolio_Project..CovidDeaths ORDER BY 3, 4;

--SELECT * FROM Portfolio_Project..CovidVaccinations ORDER BY 3, 4;

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM Portfolio_Project..CovidDeaths ORDER BY 1, 2;

-- Total_cases Vs Total_Deaths
-- Chances of dying if get infected by Covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM Portfolio_Project..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1, 2;

--Total_cases Vs Population
--Percentage of Population Infected by Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Population_infected_Percentage 
FROM Portfolio_Project..CovidDeaths
--WHERE location LIKE '%India%'
ORDER BY 1, 2;


-- Countries with Highest Infection Rate Compared to Population
-- Table 3
SELECT Location, population, MAX(total_cases) AS Highest_infected_count, MAX((total_cases/population))*100 AS Highest_population_infected_Percentage 
FROM Portfolio_Project..CovidDeaths
GROUP BY Location, population
ORDER BY Highest_population_infected_Percentage DESC;

-- Table 4
SELECT Location, population, date, MAX(total_cases) AS Highest_infected_count, MAX((total_cases/population))*100 AS Highest_population_infected_Percentage 
FROM Portfolio_Project..CovidDeaths
GROUP BY Location, population, date
ORDER BY Highest_population_infected_Percentage DESC;


-- Countries with Higher DeathCount per Population
SELECT Location, MAX(cast(total_deaths as int)) AS Death_counts
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Death_counts DESC;

-- BREAKDOWN BY CONTINENT, LOCATION
SELECT location, MAX(cast(total_deaths as int)) AS Death_counts
FROM Portfolio_Project..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY Death_counts DESC;

-- BREAKDOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) AS Death_counts
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_counts DESC;



-- GLOBAL NUMBERS
-- Table 1
SELECT  SUM(new_cases) AS Totalcases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage   
FROM Portfolio_Project..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

-- European Union is part of Europe
-- Table 2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Joining Both Tables
SELECT * 
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date;


-- Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USING CTE

With Popvsvac (Continent, Location, Date, Population, New_vaccinations, Rolling_Vaccination)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (Rolling_Vaccination/Population)*100 AS Vaccination_per_population
FROM Popvsvac
ORDER BY 2, 3;


-- Creating View To Store Data For Visaulizations
CREATE VIEW Population_vaccinated_percentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL