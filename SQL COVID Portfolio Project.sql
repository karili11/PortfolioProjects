Select *
	FROM PortfolioProject..Covid_Deaths$ 
	Where continent is not null
	order by 3,4

----Select *
----	FROM PortfolioProject..Covid_Vaccinations$
----	order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths$
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths$
Where location like '%states%' 
Where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, Population, total_cases,(total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths$
Where location like '%states%' 
Where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate copared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths$
--Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths$
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Showing Continents with the highest death count per population
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1, 2

Select *
From PortfolioProject..Covid_Vaccinations$



--Looking at Total Population vs Vaccinations
--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) *100
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) *100
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) *100
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3
	


	Select *
	From PercentPopulationVaccinated



