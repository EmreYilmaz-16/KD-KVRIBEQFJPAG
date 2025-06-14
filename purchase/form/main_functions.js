function mergeCompanies(data) {
    const result = [];

    data.forEach(entry => {
        const existing = result.find(c => c.COMPANY_ID === entry.COMPANY_ID);

        if (existing) {
            existing.URUNLER = existing.URUNLER.concat(entry.URUNLER);
        } else {
            result.push({
                FULLNAME: entry.FULLNAME,
                COMPANY_ID: entry.COMPANY_ID,
                URUNLER: [...entry.URUNLER]
            });
        }
    });

    return result;
}