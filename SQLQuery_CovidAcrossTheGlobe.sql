Select *
From PortfolioProject..CovidDeaths
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases Vs Total Cases
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
From PortfolioProject..CovidDeaths CD1
Where date = (Select max(date) from PortfolioProject..CovidDeaths CD2 Where CD1.location = CD2.Location) AND continent is not null
Order by 'Death Percentage' desc

--Total Cases Vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as 'PerPopulationInfected'
From PortfolioProject..CovidDeaths CD1
Where date = (Select max(date) from PortfolioProject..CovidDeaths CD2 Where CD1.location = CD2.Location) AND continent is not null
Order by 'PerPopulationInfected' desc

--Death Count by Continent
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by location
Order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Using CTE to show percentage of vaccinated population 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, RollingPeopleVaccinated/Population*100 as VaccinatedPopulation
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

