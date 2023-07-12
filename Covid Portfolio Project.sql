
 /* 
 COVID 19 Data Exploration

 Skills used: Joins, CTE's, Temp Table, Windows Fuctions, Aggregate Functions, Creating Views, Converting data types

 */
 
 --Converting data types and changing 0 values to null
 ALTER TABLE CovidDeaths ALTER COLUMN total_cases  FLOAT
 ALTER TABLE CovidDeaths ALTER COLUMN new_cases  FLOAT
 ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations  FLOAT
 update CovidDeaths set new_deaths = null where new_deaths = 0
 update CovidDeaths set new_cases = null where new_cases = 0

Select * 
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4


--Selecting Data to start with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


--Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2
 

--Total Cases Vs. Population
--Shows what percentage of population is infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
From [Portfolio Project]..CovidDeaths
order by 1,2


--Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentofPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by location, population
order by PercentofPopulationInfected desc


--Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


--Continents with highest death count per population

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


--Total Population vs. Vaccinations
--Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Using CTE to perform calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated

from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date