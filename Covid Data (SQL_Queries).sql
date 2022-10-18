SELECT *
FROM PortfolioProjects..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--order by 3,4
--Select data we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2

--Looking at total Cases vs total Deaths

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
where location like '%states%'
Where continent is not null
order by 1,2

--Shows likelihood of dying if you contract covid in my country of birth

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
where location like '%syria%'
Where continent is not null
order by 1,2

--Shows likelihood of dying if you contract covid in my country of citizenship

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
where location like '%canada%'
Where continent is not null
order by 1,2

--Looking at total cases vs population 
--Shows what percentage of population got covid

SELECT Location, date, Population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--where location like '%canada%'
Where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Poplation

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--where location like '%canada%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--where location like '%canada%'
Where continent is not null
Group by Location
order by TotalDeathCount desc  

--Breaking things down by Continent

-- Showing continent with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--where location like '%canada%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--where location like '%canada%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


--Creating View to store for date visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated

