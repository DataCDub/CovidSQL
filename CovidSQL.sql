SELECT *
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
order by 3,4

Select *
From `thematic-caster-391823.Covid_Data.Covid_Vaccinations`
order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
Where Location = 'United States'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location, Date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
Where Location = 'United States' 
order by 1,2

--What country has the highest infection rate compared to population

SELECT Location,Population, Max(total_cases) as HighesstInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
Where Location = 'United States'
Group by Location, Population 
order by PercentPopulationInfected desc

--Showing Countries with the Highest Death Count per Population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
Were Continent is not null
Group by location
order by TotalDeathCount desc

--Showing the Continents with the highest death count

SELECT Continent, Max(cast(total_deaths as int)) as TotalDeathCount
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
Where Location is not null and Continent is not null
Group by Continent
order by TotalDeathCount desc


--Global numbers per day

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
Where Continent is not null and new_cases >0 and new_deaths>0
GROUP BY date
ORDER BY 1,2

--Total Global Numbers 

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From `thematic-caster-391823.Covid_Data.Covid_Deaths`
Where Continent is not null and new_cases >0 and new_deaths >0
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 