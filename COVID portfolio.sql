Select *
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX((Total_deaths)) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX((Total_deaths)) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM((new_deaths)) as total_deaths, SUM((new_deaths))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM((vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;



SELECT * FROM projectportfolio.covidvaccination;


WITH PopvsVac AS 
(
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        projectportfolio.coviddeaths dea
    JOIN 
        projectportfolio.covidvaccination vac 
	ON dea.location = vac.location 
    AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL

)
-- TEMP TABLE


CREATE TABLE PercentPopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar(255),
Datetime date,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
 SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.Population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        projectportfolio.coviddeaths dea
    JOIN 
        projectportfolio.covidvaccination vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL;


SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PercentPopulationVaccinate;

-- creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinat as
 SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.Population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        projectportfolio.coviddeaths dea
    JOIN 
        projectportfolio.covidvaccination vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL;
