Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--shows the likelihood of dying if you track covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states'
order by 1,2


--looking at total cases vs population
--shows oercentage of population get covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulation
From PortfolioProject..CovidDeaths
--where location like '%states'
where location like '%ndia'
order by 1,2

--looking at countries with highest infection rate
Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states'
--where location like '%ndia'
Group by Location, population
order by 4 desc

-- let's things break down by continent


--showing the countries with the country highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
where location is not null
Group by location
--where location like '%states'
order by TotalDeathsCount desc

--showing continents with highest deathcount per population
Select continent, max(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
--where location like '%states'
order by TotalDeathsCount desc

--Breaking down the global numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
--group by date
order by 1,2
--order by DeathPercentage desc


--looking at total poupulation vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 

With PopvsVac (continent, location, date, population, New_Vaccinations,  RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPeopleVaccinated

-- Creating a view to store data for later visualization

Create View PercentPeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPeopleVaccinated