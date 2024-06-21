--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,
CASE 
WHEN TRY_CAST(total_cases AS FLOAT)=0 or TRY_CAST(total_cases AS FLOAT) IS NULL THEN NULL
ELSE TRY_CAST(total_deaths AS FLOAT)/TRY_CAST(total_cases AS FLOAT)*100
END AS Death_rate
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Kazakh%' AND continent IS NOT NULL
ORDER BY location,date


--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT location,date,total_cases,population,
CASE 
WHEN TRY_CAST(total_cases AS FLOAT)=0 or TRY_CAST(total_cases AS FLOAT) IS NULL THEN NULL
ELSE TRY_CAST(total_cases AS FLOAT)/TRY_CAST(population AS FLOAT)*100
END AS percent_of_covid
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states' AND continent IS NOT NULL
ORDER BY location,date

--Looking at countries with Highest Infection Rate compared to Population
SELECT location,
       population,
	   max(total_cases) as Highest_Infection_count,
	   MAX(TRY_CAST(total_cases AS float)/TRY_CAST(population AS FLOAT))*100 AS PercentofPopulation_infected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY LOCATION,population
ORDER BY PercentofPopulation_infected desc

--Showing countries with Highest Death count for Population
SELECT location,
       max(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

---Showing continents with Highest Death count for Population
SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT date,
       SUM(new_cases) as Total_cases,
	   SUM(CAST(new_deaths AS INT)) as Total_death,
	   SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date
 

SELECT 
       SUM(new_cases) as Total_cases,
	   SUM(CAST(new_deaths AS INT)) as Total_death,
	   SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL

--Looking at Total Population vs Total Vaccinations
SELECT death.continent,
       death.location,
	   death.date,
	   death.population,
	   vacc.new_vaccinations, 
	   SUM(CAST(VACC.new_vaccinations AS INT)) OVER(Partition by death.location ORDER BY death.location,death.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vacc
ON death.location=vacc.location
and death.date=vacc.date
WHERE death.continent is NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopVSVac as (SELECT death.continent,
       death.location,
	   death.date,
	   death.population,
	   vacc.new_vaccinations, 
	   SUM(CAST(VACC.new_vaccinations AS INT)) OVER(Partition by death.location ORDER BY death.location,death.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vacc
ON death.location=vacc.location
and death.date=vacc.date
WHERE death.continent is NOT NULL) 

SELECT *,(total_vaccinations/population)*100 
FROM PopVSVac
--WHERE location='Albania'
ORDER BY location,date

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinations numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent,
       death.location,
	   death.date,
	   death.population,
	   vacc.new_vaccinations, 
	   SUM(CAST(VACC.new_vaccinations AS INT)) OVER(Partition by death.location ORDER BY death.location,death.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vacc
ON death.location=vacc.location
and death.date=vacc.date
--WHERE death.continent is NOT NULL

SELECT *,(total_vaccinations/population)*100 as PercentPeopleVaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location,Date


--CREATING VIEW to store data for later visualizations
USE PortfolioProject
GO
Create View PercPopulationVaccinated as 
SELECT death.continent,
       death.location,
	   death.date,
	   death.population,
	   vacc.new_vaccinations, 
	   SUM(CAST(VACC.new_vaccinations AS INT)) OVER(Partition by death.location ORDER BY death.location,death.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vacc
ON death.location=vacc.location
and death.date=vacc.date
WHERE death.continent is NOT NULL



















