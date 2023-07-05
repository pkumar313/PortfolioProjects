/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order By CovidDeaths.location, CovidDeaths.date

SELECT *
FROM PortfolioProject..CovidVaccinations
Order By 3,4

-- Select the Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order By 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)* 100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
Order By 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases / population)* 100 AS InfectedPopulationPercentage
FROM CovidDeaths
--WHERE location like '%states%'
Order By 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))* 100 AS InfectedPopulationPercentage
FROM CovidDeaths
--WHERE location like '%states%'
Group By location, population
Order By InfectedPopulationPercentage desc 


-- Looking at countries with the highest Death Count Per Population
SELECT location, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
Group By location
Order By HighestDeathCount desc 


-- Looking at Continents with the highest Death Count Per Population
SELECT location, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent is null
Group By location
Order By HighestDeathCount desc 


-- Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(Cast(new_deaths as int)) AS TotalDeaths, (SUM(Cast(new_deaths as int)) / SUM(new_cases)) * 100 AS DeathPercentage --, total_deaths, (total_deaths / total_cases)* 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--Group By date
Order By 1,2


-- Looking as Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) OVER (Partition By cv.location Order By cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
Where cd.continent is not null
Order By 2,3


-- Looking at Percentage Population that have been Vaccinated
------------------------------------------------------------------------------------------------------------------------------
-- USE a CTE
With PopsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) OVER (Partition By cv.location Order By cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
Where cd.continent is not null
--Order By 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100 
FROM PopsVac


-- OR USE a Temp Table
DROP Table IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) OVER (Partition By cv.location Order By cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
Where cd.continent is not null
--Order By 2,3
SELECT *, (RollingPeopleVaccinated/population) * 100 
FROM #PercentPopulationVaccinated
Order By 2,3

-------------------------------------------------------------------------------------------------------------------------------

-- Creating View to Store Data for Later Visualizations
Create View PercentPopulationVaccinated as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) OVER (Partition By cv.location Order By cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
Where cd.continent is not null
--Order By 2,3
)