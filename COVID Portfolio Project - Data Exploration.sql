/*

COVID 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3

Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3

--Select Data that we are going to be using

Select location, date, total_cases, new_cases_smoothed, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
	and continent is not null
order by 1

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
	and continent is not null
order by 1

--Looking at countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, (CONVERT(float, Max(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--Showing countries with the highest death count by population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Lets break things down by continent

--Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where not continent= ''
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, Sum(cast(new_cases as int)) as Total_New_Cases, Sum(cast(new_deaths as int)) as Total_New_Deaths, 
	--Sum(cast(new_deaths as int))/Sum(Nullif(cast(new_cases as int),0))* 100 as Death_Percentage
	SUM(CONVERT(float, total_deaths)) / SUM(NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
	--Sum(CONVERT(float, new_deaths)) / Sum(NULLIF(CONVERT(float, new_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1


----------------------------------------------------------------------------------------------------------------------
--VACCINATIONS

--Looking at Total Population vs Vaccination

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(float,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population) * 100 

	--Select date, Sum(cast(new_cases as int)) as Total_New_Cases, Sum(cast(new_deaths as int)) as Total_New_Deaths, 
	----Sum(cast(new_deaths as int))/Sum(Nullif(cast(new_cases as int),0))* 100 as Death_Percentage
	--SUM(CONVERT(float, total_deaths)) / SUM(NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage


From PortfolioProject..CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where Not dea.continent = ''
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)* 100
From PopVsVac
Order by 2,3

--Use CTE

With PopVsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(float,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population) * 100 

	--Select date, Sum(cast(new_cases as int)) as Total_New_Cases, Sum(cast(new_deaths as int)) as Total_New_Deaths, 
	----Sum(cast(new_deaths as int))/Sum(Nullif(cast(new_cases as int),0))* 100 as Death_Percentage
	--SUM(CONVERT(float, total_deaths)) / SUM(NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage

From PortfolioProject..CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where Not dea.continent = ''
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)* 100
From #PercentPopulationVaccinated



--Creating a View to store data for later visualizations

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(float,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population) * 100 

	--Select date, Sum(cast(new_cases as int)) as Total_New_Cases, Sum(cast(new_deaths as int)) as Total_New_Deaths, 
	----Sum(cast(new_deaths as int))/Sum(Nullif(cast(new_cases as int),0))* 100 as Death_Percentage
	--SUM(CONVERT(float, total_deaths)) / SUM(NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage

From PortfolioProject..CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where Not dea.continent = ''
--Order by 2,3


Select *
From PercentPopulationVaccinated