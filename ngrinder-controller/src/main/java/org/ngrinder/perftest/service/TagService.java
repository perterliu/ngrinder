/*
 * Copyright (C) 2012 - 2012 NHN Corporation
 * All rights reserved.
 *
 * This file is part of The nGrinder software distribution. Refer to
 * the file LICENSE which is part of The nGrinder distribution for
 * licensing details. The nGrinder distribution is available on the
 * Internet at http://nhnopensource.org/ngrinder
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.ngrinder.perftest.service;

import static org.ngrinder.perftest.repository.TagSpecification.lastModifiedOrCreatedBy;
import static org.ngrinder.perftest.repository.TagSpecification.valueIn;

import java.util.List;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

import org.ngrinder.model.PerfTest;
import org.ngrinder.model.Role;
import org.ngrinder.model.Tag;
import org.ngrinder.model.User;
import org.ngrinder.perftest.repository.TagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specifications;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Tag Service. Tag support which is used to categorize {@link PerfTest}
 * 
 * @author JunHo Yoon
 * @since 3.0
 * 
 */
@Service
public class TagService {
	@Autowired
	private TagRepository tagRepository;

	@Transactional
	public Set<Tag> addTags(User user, String[] tags) {
		Specifications<Tag> spec = Specifications.where(valueIn(tags));

		if (user.getRole() == Role.USER) {
			spec = spec.and(lastModifiedOrCreatedBy(user));
		}
		List<Tag> foundTags = tagRepository.findAll(spec);
		SortedSet<Tag> allTags = new TreeSet<Tag>(foundTags);
		for (String each : tags) {
			Tag newTag = new Tag(each);
			if (!foundTags.contains(newTag)) {
				allTags.add(tagRepository.save(newTag));
			}
		}
		return allTags;
	}
}
