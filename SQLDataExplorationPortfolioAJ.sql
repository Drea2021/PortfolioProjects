/* 
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths
Where continent is not null
order by 3, 4 


-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From CovidDeaths
Where location like '%state%'
order by 1, 2

-- Total Cases vs Population
--Shows what % of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 PercentagePopInfected
From CovidDeaths
--Where location like '%state%'
order by 1, 2

-- Countries with highest infection rate compared to population

Select Location, Population, Max(total_cases) HighestInfectCount, Max((total_cases/population))*100 PercentagePopInfected
From CovidDeaths
--Where location like '%state%'
Group by Location, population
Order by PercentagePopInfected desc


-- Countries with highest death count per population
Select Location, Max(cast(Total_deaths as int)) TotalDeathCount
From CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Break things down by continent

-- Showing the continents with the highest death counts per population
Select Location, Max(cast(Total_deaths as int)) TotalDeathCount
From CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- Global numbers
Select SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
	DeathPercentage
From CovidDeaths
-- Where location like '%state%'
Where continent is not null
--Group by date
Order by 1, 2


-- Total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join Covidvaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE to perform Calculation on Partition By in previous query
with PopvsVac (Continent, Location,Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join Covidvaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Using Temp Table to perform calculation on partition by in previous query

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join Covidvaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join Covidvaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated